package auth

import (
	"context"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
)

const (
	fxaAuthServer   = "https://api.accounts.firefox.com/v1"
	firefoxClientID = "5882386c6d801776"
	oauthScope      = "profile https://identity.mozilla.com/apps/vpn"
	protocolVersion = "identity.mozilla.com/picl/v1/"
)

type LoginResponse struct {
	SessionToken       string `json:"sessionToken"`
	Verified           bool   `json:"verified"`
	UID                string `json:"uid"`
	VerificationMethod string `json:"verificationMethod"`
	VerificationReason string `json:"verificationReason"`
}

type tokenResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int64  `json:"expires_in"`
}

func pbkdf2SHA256(password, salt []byte, rounds, keyLen int) []byte {
	hLen := sha256.Size
	blocks := (keyLen + hLen - 1) / hLen
	out := make([]byte, 0, blocks*hLen)
	for block := 1; block <= blocks; block++ {
		m := hmac.New(sha256.New, password)
		m.Write(salt)
		m.Write([]byte{byte(block >> 24), byte(block >> 16), byte(block >> 8), byte(block)})
		u := m.Sum(nil)
		t := append([]byte(nil), u...)
		for i := 1; i < rounds; i++ {
			m = hmac.New(sha256.New, password)
			m.Write(u)
			u = m.Sum(nil)
			for j := range t {
				t[j] ^= u[j]
			}
		}
		out = append(out, t...)
	}
	return out[:keyLen]
}

func hkdfSHA256(secret, salt, info []byte, n int) []byte {
	if salt == nil {
		salt = make([]byte, sha256.Size)
	}
	extract := hmac.New(sha256.New, salt)
	extract.Write(secret)
	prk := extract.Sum(nil)

	out := make([]byte, 0, n)
	var prev []byte
	for counter := byte(1); len(out) < n; counter++ {
		expand := hmac.New(sha256.New, prk)
		expand.Write(prev)
		expand.Write(info)
		expand.Write([]byte{counter})
		prev = expand.Sum(nil)
		out = append(out, prev...)
	}
	return out[:n]
}

func deriveAuthPW(email, password string) ([]byte, error) {
	salt := []byte(protocolVersion + "quickStretch:" + strings.ToLower(strings.TrimSpace(email)))
	quick := pbkdf2SHA256([]byte(password), salt, 1000, 32)
	return hkdfSHA256(quick, []byte{0}, []byte(protocolVersion+"authPW"), 32), nil
}

func deriveHawkCredentials(tokenHex string) (string, []byte, error) {
	token, err := hex.DecodeString(tokenHex)
	if err != nil {
		return "", nil, err
	}
	out := hkdfSHA256(token, nil, []byte(protocolVersion+"sessionToken"), 96)
	return hex.EncodeToString(out[:32]), out[32:64], nil
}

func hawkHeader(method, rawURL, id string, key []byte, payload string) (string, error) {
	u, err := url.Parse(rawURL)
	if err != nil {
		return "", err
	}
	nonce := make([]byte, 6)
	if _, err := rand.Read(nonce); err != nil {
		return "", err
	}
	ts := fmt.Sprintf("%d", time.Now().Unix())
	port := u.Port()
	if port == "" {
		if u.Scheme == "https" {
			port = "443"
		} else {
			port = "80"
		}
	}
	payloadHash := ""
	if payload != "" {
		h := sha256.New()
		h.Write([]byte("hawk.1.payload\napplication/json\n"))
		h.Write([]byte(payload))
		h.Write([]byte("\n"))
		payloadHash = hex.EncodeToString(h.Sum(nil))
	}
	normalized := strings.Join([]string{
		"hawk.1.header", ts, hex.EncodeToString(nonce), strings.ToUpper(method),
		u.RequestURI(), u.Hostname(), port, payloadHash, "", "",
	}, "\n")
	m := hmac.New(sha256.New, key)
	m.Write([]byte(normalized))
	h := fmt.Sprintf(`Hawk id="%s", ts="%s", nonce="%s", mac="%s"`,
		id, ts, hex.EncodeToString(nonce), hex.EncodeToString(m.Sum(nil)))
	if payloadHash != "" {
		h += fmt.Sprintf(`, hash="%s"`, payloadHash)
	}
	return h, nil
}

func Login(ctx context.Context, email, password string) (*LoginResponse, error) {
	authPW, err := deriveAuthPW(email, password)
	if err != nil {
		return nil, err
	}
	body, _ := json.Marshal(map[string]string{
		"email":              strings.TrimSpace(email),
		"authPW":             hex.EncodeToString(authPW),
		"verificationMethod": "email-2fa",
	})
	resp, err := fxaRequest(ctx, http.MethodPost, fxaAuthServer+"/account/login", body, "")
	if err != nil {
		return nil, err
	}
	data, _ := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	_ = resp.Body.Close()
	if resp.StatusCode == http.StatusBadRequest {
		var apiError struct {
			Errno int `json:"errno"`
		}
		if json.Unmarshal(data, &apiError) == nil && apiError.Errno == 107 {
			body, _ = json.Marshal(map[string]string{
				"email":  strings.TrimSpace(email),
				"authPW": hex.EncodeToString(authPW),
			})
			resp, err = fxaRequest(ctx, http.MethodPost, fxaAuthServer+"/account/login", body, "")
			if err != nil {
				return nil, err
			}
			data, _ = io.ReadAll(io.LimitReader(resp.Body, 1<<20))
			_ = resp.Body.Close()
		}
	}
	if resp.StatusCode != http.StatusOK {
		if resp.StatusCode == http.StatusNotAcceptable {
			return nil, fmt.Errorf("Firefox Accounts returned HTTP 406 (Fastly client challenge)")
		}
		return nil, fmt.Errorf("Firefox Accounts login HTTP %d: %s", resp.StatusCode, strings.TrimSpace(string(data)))
	}
	var out LoginResponse
	if err := json.Unmarshal(data, &out); err != nil {
		return nil, err
	}
	if out.SessionToken == "" {
		return nil, fmt.Errorf("Firefox Accounts returned an empty session token")
	}
	return &out, nil
}

func VerifyCode(ctx context.Context, sessionToken, code string) error {
	id, key, err := deriveHawkCredentials(sessionToken)
	if err != nil {
		return err
	}
	body, _ := json.Marshal(map[string]string{"code": strings.TrimSpace(code)})
	rawURL := fxaAuthServer + "/session/verify_code"
	hawk, err := hawkHeader(http.MethodPost, rawURL, id, key, string(body))
	if err != nil {
		return err
	}
	resp, err := fxaRequest(ctx, http.MethodPost, rawURL, body, hawk)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	data, _ := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("verification HTTP %d: %s", resp.StatusCode, strings.TrimSpace(string(data)))
	}
	return nil
}

func OAuthFromSession(ctx context.Context, sessionToken string) (Tokens, error) {
	id, key, err := deriveHawkCredentials(sessionToken)
	if err != nil {
		return Tokens{}, err
	}
	body, _ := json.Marshal(map[string]any{
		"client_id":   firefoxClientID,
		"grant_type":  "fxa-credentials",
		"scope":       oauthScope,
		"access_type": "offline",
	})
	rawURL := fxaAuthServer + "/oauth/token"
	hawk, err := hawkHeader(http.MethodPost, rawURL, id, key, string(body))
	if err != nil {
		return Tokens{}, err
	}
	resp, err := fxaRequest(ctx, http.MethodPost, rawURL, body, hawk)
	if err != nil {
		return Tokens{}, err
	}
	defer resp.Body.Close()
	data, _ := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if resp.StatusCode != http.StatusOK {
		return Tokens{}, fmt.Errorf("OAuth token HTTP %d: %s", resp.StatusCode, strings.TrimSpace(string(data)))
	}
	var tr tokenResponse
	if err := json.Unmarshal(data, &tr); err != nil {
		return Tokens{}, err
	}
	if tr.AccessToken == "" {
		return Tokens{}, fmt.Errorf("OAuth response contained no access token")
	}
	return Tokens{
		AccessToken:   tr.AccessToken,
		RefreshToken:  tr.RefreshToken,
		ExpiresAtUnix: time.Now().Add(time.Duration(tr.ExpiresIn) * time.Second).Unix(),
	}, nil
}

func Refresh(ctx context.Context, refresh string) (Tokens, error) {
	body, _ := json.Marshal(map[string]any{
		"client_id":     firefoxClientID,
		"grant_type":    "refresh_token",
		"refresh_token": refresh,
		"scope":         oauthScope,
	})
	resp, err := fxaRequest(ctx, http.MethodPost, fxaAuthServer+"/oauth/token", body, "")
	if err != nil {
		return Tokens{}, err
	}
	defer resp.Body.Close()
	data, _ := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if resp.StatusCode != http.StatusOK {
		return Tokens{}, fmt.Errorf("refresh token HTTP %d: %s", resp.StatusCode, strings.TrimSpace(string(data)))
	}
	var tr tokenResponse
	if err := json.Unmarshal(data, &tr); err != nil {
		return Tokens{}, err
	}
	if tr.RefreshToken == "" {
		tr.RefreshToken = refresh
	}
	return Tokens{
		AccessToken:   tr.AccessToken,
		RefreshToken:  tr.RefreshToken,
		ExpiresAtUnix: time.Now().Add(time.Duration(tr.ExpiresIn) * time.Second).Unix(),
	}, nil
}

func ValidTokens(ctx context.Context) (Tokens, error) {
	t, err := LoadTokens()
	if err != nil {
		return Tokens{}, err
	}
	if !t.ExpiredSoon() {
		return t, nil
	}
	if t.RefreshToken == "" {
		return Tokens{}, fmt.Errorf("access token expired and no refresh token is saved")
	}
	n, err := Refresh(ctx, t.RefreshToken)
	if err != nil {
		return Tokens{}, err
	}
	if err := SaveTokens(n); err != nil {
		return Tokens{}, err
	}
	return n, nil
}
