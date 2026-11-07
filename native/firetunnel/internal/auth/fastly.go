package auth

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"regexp"
	"strings"
	"time"
)

const (
	fastlySolverUserAgent     = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"
	fastlyFirefoxVpnUserAgent = "MozillaVPN/2.35.0 (sys:linux; iap:true)"
	fastlyHTMLAccept          = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
	fastlyPowAlphabet         = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
)

var (
	fastlyPrefixRE  = regexp.MustCompile(`/(_fs-ch-[A-Za-z0-9]+)`)
	fxaCookieJar, _ = cookiejar.New(nil)
	fxaHTTPClient   = &http.Client{Jar: fxaCookieJar, Timeout: 60 * time.Second}
)

type fastlyChallengeError struct{ message string }

func (e fastlyChallengeError) Error() string { return e.message }

func fxaRequest(ctx context.Context, method, rawURL string, body []byte, authorization string) (*http.Response, error) {
	for attempt := 0; attempt < 5; attempt++ {
		req, err := http.NewRequestWithContext(ctx, method, rawURL, bytes.NewReader(body))
		if err != nil {
			return nil, err
		}
		req.Header.Set("Content-Type", "application/json")
		req.Header.Set("User-Agent", fastlySolverUserAgent)
		req.Header.Set("Accept", "application/json")
		if authorization != "" {
			req.Header.Set("Authorization", authorization)
		}
		resp, err := fxaHTTPClient.Do(req)
		if err != nil {
			return nil, err
		}
		if resp.StatusCode != http.StatusNotAcceptable {
			return resp, nil
		}
		challengeBody, _ := io.ReadAll(io.LimitReader(resp.Body, 2<<20))
		_ = resp.Body.Close()
		if attempt == 4 {
			return nil, fmt.Errorf("Firefox Accounts kept returning HTTP 406 after Fastly challenge attempts")
		}
		parsedURL, _ := url.Parse(rawURL)
		origin := ""
		if parsedURL != nil {
			origin = parsedURL.Scheme + "://" + parsedURL.Host
		}
		if err := solveFastlyChallenge(ctx, string(challengeBody), origin); err != nil {
			return nil, fmt.Errorf("Firefox Accounts HTTP 406; Fastly verification failed: %w", err)
		}
	}
	return nil, fmt.Errorf("Firefox Accounts request retries exhausted")
}

func solveFastlyChallenge(ctx context.Context, challengedPage, challengedOrigin string) error {
	if looksLikeFastlyChallenge(challengedPage) && strings.HasPrefix(challengedOrigin, "https://") {
		return solveFastlyChallengeAt(ctx, challengedOrigin, challengedPage, fastlySolverUserAgent)
	}
	var lastErr error
	for _, origin := range []string{"https://api.accounts.firefox.com", "https://accounts.firefox.com"} {
		for _, userAgent := range []string{fastlyFirefoxVpnUserAgent, fastlySolverUserAgent} {
			if err := solveFastlyChallengeAt(ctx, origin, "", userAgent); err == nil {
				return nil
			} else if err.Error() != "no Fastly challenge page" {
				lastErr = err
			}
		}
	}
	if lastErr != nil {
		return lastErr
	}
	return fastlyChallengeError{"Firefox Accounts did not provide a Fastly challenge page"}
}

func solveFastlyChallengeAt(ctx context.Context, origin, challengedPage, userAgent string) error {
	jar, err := cookiejar.New(nil)
	if err != nil {
		return err
	}
	if parsedOrigin, parseErr := url.Parse(origin + "/"); parseErr == nil {
		jar.SetCookies(parsedOrigin, fxaCookieJar.Cookies(parsedOrigin))
	}
	client := &http.Client{Jar: jar, Timeout: 60 * time.Second}
	pageURL := strings.TrimRight(origin, "/") + "/"
	page := challengedPage
	if page == "" {
		page, err = fastlyFetchPage(ctx, client, pageURL, userAgent)
		if err != nil {
			return err
		}
	}
	if !looksLikeFastlyChallenge(page) {
		return fastlyChallengeError{"no Fastly challenge page"}
	}
	prefixMatch := fastlyPrefixRE.FindStringSubmatch(page)
	if len(prefixMatch) < 2 {
		return fastlyChallengeError{"Fastly challenge asset prefix was not found"}
	}
	prefixURL := strings.TrimRight(origin, "/") + "/" + prefixMatch[1]
	script, err := fastlyFetchText(ctx, client, prefixURL+"/script.js?reload=true", fastlyHTMLAccept, userAgent)
	if err != nil {
		return err
	}
	var challenges []map[string]any
	var token string
	challenges, token, err = parseFastlyInit(script)
	if err != nil {
		return err
	}
	for round := 0; round < 3; round++ {
		answers := make([]map[string]any, 0, len(challenges))
		for _, challenge := range challenges {
			answer, err := fastlyAnswer(ctx, client, origin, prefixURL, token, challenge, userAgent)
			if err != nil {
				return err
			}
			answers = append(answers, answer)
		}
		payload, err := json.Marshal(map[string]any{"token": token, "data": answers})
		if err != nil {
			return err
		}
		postURL := prefixURL + "/fst-post-back"
		req, err := http.NewRequestWithContext(ctx, http.MethodPost, postURL, bytes.NewReader(payload))
		if err != nil {
			return err
		}
		req.Header.Set("Content-Type", "application/json")
		req.Header.Set("Accept", "application/json")
		req.Header.Set("User-Agent", userAgent)
		req.Header.Set("Origin", origin)
		resp, err := client.Do(req)
		if err != nil {
			return err
		}
		responseBody, readErr := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
		_ = resp.Body.Close()
		if readErr != nil {
			return readErr
		}
		if resp.StatusCode < 200 || resp.StatusCode >= 300 {
			return fastlyChallengeError{fmt.Sprintf("Fastly challenge response returned HTTP %d", resp.StatusCode)}
		}
		var result struct {
			Status     string           `json:"status"`
			Challenges []map[string]any `json:"ch"`
			Token      string           `json:"tok"`
		}
		if err := json.Unmarshal(responseBody, &result); err != nil {
			return fastlyChallengeError{"Fastly challenge response could not be parsed"}
		}
		if result.Status == "success" {
			page, err := fastlyFetchPage(ctx, client, pageURL, userAgent)
			if err != nil {
				return err
			}
			if looksLikeFastlyChallenge(page) {
				return fastlyChallengeError{"Fastly challenge cookie was not accepted"}
			}
			apiURL, _ := url.Parse("https://api.accounts.firefox.com/")
			cookies := jar.Cookies(apiURL)
			if len(cookies) == 0 {
				cookies = jar.Cookies(mustParseURL(origin + "/"))
			}
			if len(cookies) == 0 {
				return fastlyChallengeError{"Fastly challenge completed but issued no Firefox Account cookies"}
			}
			for _, cookie := range cookies {
				copy := *cookie
				copy.Domain = "firefox.com"
				copy.Path = "/"
				copy.Secure = true
				fxaCookieJar.SetCookies(apiURL, []*http.Cookie{&copy})
			}
			return nil
		}
		if len(result.Challenges) == 0 || result.Token == "" {
			return fastlyChallengeError{"Fastly challenge returned no next challenge"}
		}
		challenges, token = result.Challenges, result.Token
	}
	return fastlyChallengeError{"Fastly challenge did not complete within three rounds"}
}

func parseFastlyInit(script string) ([]map[string]any, string, error) {
	arrayStart := -1
	searchAt := 0
	for searchAt < len(script) {
		relative := strings.Index(script[searchAt:], "init(")
		if relative < 0 {
			break
		}
		open := searchAt + relative + len("init(")
		for open < len(script) && (script[open] == ' ' || script[open] == '\t' || script[open] == '\r' || script[open] == '\n') {
			open++
		}
		if open < len(script) && script[open] == '[' {
			arrayStart = open
		}
		searchAt = open + 1
	}
	if arrayStart < 0 {
		return nil, "", fastlyChallengeError{"Fastly challenge init call was not found"}
	}

	depth := 0
	inString := false
	escaped := false
	arrayEnd := -1
	for i := arrayStart; i < len(script); i++ {
		ch := script[i]
		if inString {
			if escaped {
				escaped = false
			} else if ch == '\\' {
				escaped = true
			} else if ch == '"' {
				inString = false
			}
			continue
		}
		switch ch {
		case '"':
			inString = true
		case '[':
			depth++
		case ']':
			depth--
			if depth == 0 {
				arrayEnd = i
				i = len(script)
			}
		}
	}
	if arrayEnd < arrayStart {
		return nil, "", fastlyChallengeError{"Fastly challenge array was incomplete"}
	}
	var challenges []map[string]any
	if err := json.Unmarshal([]byte(script[arrayStart:arrayEnd+1]), &challenges); err != nil || len(challenges) == 0 {
		return nil, "", fastlyChallengeError{"Fastly challenge list could not be parsed"}
	}

	pos := arrayEnd + 1
	for pos < len(script) && (script[pos] == ' ' || script[pos] == '\t' || script[pos] == '\r' || script[pos] == '\n') {
		pos++
	}
	if pos >= len(script) || script[pos] != ',' {
		return nil, "", fastlyChallengeError{"Fastly challenge token separator was not found"}
	}
	pos++
	for pos < len(script) && (script[pos] == ' ' || script[pos] == '\t' || script[pos] == '\r' || script[pos] == '\n') {
		pos++
	}
	if pos >= len(script) || script[pos] != '"' {
		return nil, "", fastlyChallengeError{"Fastly challenge token was not a string"}
	}
	start := pos
	escaped = false
	for pos++; pos < len(script); pos++ {
		if escaped {
			escaped = false
		} else if script[pos] == '\\' {
			escaped = true
		} else if script[pos] == '"' {
			var token string
			if err := json.Unmarshal([]byte(script[start:pos+1]), &token); err != nil || token == "" {
				return nil, "", fastlyChallengeError{"Fastly challenge token could not be parsed"}
			}
			return challenges, token, nil
		}
	}
	return nil, "", fastlyChallengeError{"Fastly challenge token was incomplete"}
}

func mustParseURL(raw string) *url.URL {
	u, _ := url.Parse(raw)
	return u
}

func looksLikeFastlyChallenge(body string) bool {
	if len(body) == 0 || len(body) > 2<<20 || !fastlyPrefixRE.MatchString(body) {
		return false
	}
	lower := strings.ToLower(body)
	return strings.Contains(lower, "client challenge") ||
		strings.Contains(body, "script.js") || strings.Contains(body, "fst-post-back")
}

func fastlyFetchPage(ctx context.Context, client *http.Client, rawURL, userAgent string) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, rawURL, nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("User-Agent", userAgent)
	req.Header.Set("Accept", fastlyHTMLAccept)
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(io.LimitReader(resp.Body, 2<<20))
	return string(body), err
}

func fastlyFetchText(ctx context.Context, client *http.Client, rawURL, accept, userAgent string) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, rawURL, nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("User-Agent", userAgent)
	req.Header.Set("Accept", accept)
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(io.LimitReader(resp.Body, 2<<20))
	if err != nil {
		return "", err
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return "", fastlyChallengeError{fmt.Sprintf("Fastly challenge GET returned HTTP %d", resp.StatusCode)}
	}
	return string(body), nil
}

func fastlyAnswer(ctx context.Context, client *http.Client, origin, prefixURL, token string, challenge map[string]any, userAgent string) (map[string]any, error) {
	typ, _ := challenge["ty"].(string)
	data, _ := challenge["data"].(map[string]any)
	if data == nil {
		data = map[string]any{}
	}
	switch typ {
	case "pow":
		base, _ := data["base"].(string)
		targetHex, _ := data["hash"].(string)
		target, err := hex.DecodeString(targetHex)
		if err != nil || len(target) != sha256.Size {
			return nil, fastlyChallengeError{"Fastly proof-of-work challenge is malformed"}
		}
		answer := ""
		for i := 0; i < len(fastlyPowAlphabet) && answer == ""; i++ {
			for j := 0; j < len(fastlyPowAlphabet); j++ {
				suffix := string([]byte{fastlyPowAlphabet[i], fastlyPowAlphabet[j]})
				hash := sha256.Sum256([]byte(base + suffix))
				if bytes.Equal(hash[:], target) {
					answer = suffix
					break
				}
			}
			if i&7 == 0 {
				select {
				case <-ctx.Done():
					return nil, ctx.Err()
				default:
				}
			}
		}
		if answer == "" {
			return nil, fastlyChallengeError{"Fastly proof-of-work challenge could not be solved"}
		}
		return map[string]any{"ty": "pow", "base": base, "answer": answer, "hmac": data["hmac"], "expires": data["expires"]}, nil
	case "pat":
		patURL := prefixURL + "/pat?token=" + url.QueryEscape(token)
		req, err := http.NewRequestWithContext(ctx, http.MethodPost, patURL, bytes.NewReader(nil))
		if err != nil {
			return nil, err
		}
		req.Header.Set("Accept", "text/plain")
		req.Header.Set("Content-Type", "application/json")
		req.Header.Set("User-Agent", userAgent)
		req.Header.Set("Origin", origin)
		resp, err := client.Do(req)
		if err != nil {
			return nil, err
		}
		body, readErr := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
		_ = resp.Body.Close()
		if readErr != nil {
			return nil, readErr
		}
		if resp.StatusCode == http.StatusBadRequest || resp.StatusCode == http.StatusUnauthorized {
			return map[string]any{"ty": "pat", "auth": ""}, nil
		}
		if resp.StatusCode < 200 || resp.StatusCode >= 300 {
			return nil, fastlyChallengeError{fmt.Sprintf("Fastly PAT request returned HTTP %d", resp.StatusCode)}
		}
		var result struct {
			Auth string `json:"auth"`
		}
		if err := json.Unmarshal(body, &result); err != nil {
			return nil, fastlyChallengeError{"Fastly PAT response could not be parsed"}
		}
		return map[string]any{"ty": "pat", "auth": result.Auth}, nil
	case "clientmetrics":
		return map[string]any{
			"ty": "clientmetrics", "webdriver": false, "v": 2,
			"bot_detection_result": map[string]any{"bot_detected": false, "bot_kind": nil},
			"browser_metrics":      map[string]any{"client_data": "{}", "error_trace": nil},
			"detector_results":     map[string]any{},
		}, nil
	default:
		return nil, fastlyChallengeError{fmt.Sprintf("unsupported Fastly challenge type %q", typ)}
	}
}
