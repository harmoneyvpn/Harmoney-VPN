package io.harmoney.client

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.webkit.CookieManager
import android.webkit.JavascriptInterface
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import io.harmoney.client.firefox.data.AppLogger
import io.harmoney.client.firefox.data.ControlPlaneHttp
import io.harmoney.client.firefox.data.FxaAuthRepository
import io.harmoney.client.firefox.data.TokenStore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.lang.ref.WeakReference

private const val LOGIN_URL =
    "https://accounts.firefox.com/?context=fx_desktop_v3&service=sync&action=email"
private const val LOGIN_TAG = "FirefoxBrowserLogin"

private const val FXA_CHANNEL_ID = "account_updates"
private const val CMD_FXA_STATUS = "fxaccounts:fxa_status"
private const val CMD_CAN_LINK_ACCOUNT = "fxaccounts:can_link_account"
private const val CMD_LOGIN = "fxaccounts:login"

private val SESSION_TOKEN_HEX = Regex("^[0-9a-f]{64}$")

private val FIREFOX_ANDROID_UA =
    "Mozilla/5.0 (Android ${Build.VERSION.RELEASE.ifBlank { "14" }}; Mobile; rv:135.0) Gecko/135.0 Firefox/135.0"

private fun jsString(value: String): String = JSONObject.quote(value)

private val WEBCHANNEL_HOOK_JS = """
(function() {
  if (window.__foxyChannelHooked) return;
  window.__foxyChannelHooked = true;
  var forward = function (detail) {
    try {
      var host = window.location.hostname;
      if (host !== 'accounts.firefox.com' && !host.endsWith('.firefox.com')) return;
      var payload = typeof detail === 'string' ? detail : JSON.stringify(detail);
      foxyWebChannel.onMessage(payload, window.location.href);
    } catch (e) {}
  };
  window.addEventListener('WebChannelMessageToChrome', function (e) { forward(e.detail); });
  document.addEventListener('WebChannelMessageToChrome', function (e) { forward(e.detail); });
  window.__foxyReply = function (channelId, messageId, command, dataJson) {
    try {
      var parsedData = typeof dataJson === 'string' ? JSON.parse(dataJson) : dataJson;
      var envelope = {
        id: channelId,
        message: { messageId: messageId, command: command, data: parsedData }
      };
      var eventObj = new CustomEvent('WebChannelMessageToContent', { detail: envelope });
      window.dispatchEvent(eventObj);
      document.dispatchEvent(eventObj);
      var eventStr = new CustomEvent('WebChannelMessageToContent', { detail: JSON.stringify(envelope) });
      window.dispatchEvent(eventStr);
      document.dispatchEvent(eventStr);
    } catch (e) {}
  };
  var getUrlString = function(arg) {
    if (!arg) return '';
    if (typeof arg === 'string') return arg;
    if (typeof arg.url === 'string') return arg.url;
    if (typeof arg.href === 'string') return arg.href;
    try { return arg.toString(); } catch (e) { return ''; }
  };
  var checkVerifyUrl = function(url) {
    var u = getUrlString(url).toLowerCase();
    return u.indexOf('/verify') !== -1 || u.indexOf('/totp') !== -1 || u.indexOf('/session/verify') !== -1 ||
           u.indexOf('enter_code') !== -1 || u.indexOf('confirm_signin') !== -1 || u.indexOf('confirm_email') !== -1;
  };
  var checkSuccessUrl = function(url) {
    var u = getUrlString(url).toLowerCase();
    return u.indexOf('confirmed') !== -1 || u.indexOf('connect_another_device') !== -1 ||
           u.indexOf('/pair') !== -1 || u.indexOf('/settings') !== -1 || u.indexOf('/complete') !== -1 ||
           u.indexOf('/verified') !== -1 || u.indexOf('success') !== -1;
  };
  if (window.fetch) {
    var origFetch = window.fetch;
    window.fetch = function() {
      var reqUrl = (arguments[0] && arguments[0].url) || arguments[0] || '';
      return origFetch.apply(this, arguments).then(function(res) {
        try {
          if (res && res.ok && checkVerifyUrl(reqUrl)) {
            foxyWebChannel.onSessionVerified();
          }
        } catch (e) {}
        return res;
      });
    };
  }
  if (window.XMLHttpRequest) {
    var origOpen = XMLHttpRequest.prototype.open;
    var origSend = XMLHttpRequest.prototype.send;
    XMLHttpRequest.prototype.open = function(method, url) {
      this.__foxyReqUrl = url;
      return origOpen.apply(this, arguments);
    };
    XMLHttpRequest.prototype.send = function() {
      this.addEventListener('load', function() {
        try {
          if (this.status >= 200 && this.status < 300 && checkVerifyUrl(this.__foxyReqUrl)) {
            foxyWebChannel.onSessionVerified();
          }
        } catch (e) {}
      });
      return origSend.apply(this, arguments);
    };
  }
  var notifyNav = function() {
    try {
      if (checkSuccessUrl(window.location.href)) {
        foxyWebChannel.onSessionVerified();
      }
    } catch (e) {}
  };
  var origPushState = history.pushState;
  if (origPushState) {
    history.pushState = function() {
      var ret = origPushState.apply(this, arguments);
      notifyNav();
      return ret;
    };
  }
  var origReplaceState = history.replaceState;
  if (origReplaceState) {
    history.replaceState = function() {
      var ret = origReplaceState.apply(this, arguments);
      notifyNav();
      return ret;
    };
  }
  window.addEventListener('popstate', notifyNav);
  window.addEventListener('hashchange', notifyNav);
})();
""".trimIndent()

class FirefoxBrowserLoginActivity : Activity() {
    private val activityScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private lateinit var webView: WebView
    private lateinit var progress: ProgressBar
    private lateinit var status: TextView
    private lateinit var authRepository: FxaAuthRepository
    private var bridge: WebChannelBridge? = null
    private var completing = false

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        window.statusBarColor = Color.rgb(11, 33, 42)
        window.navigationBarColor = Color.rgb(11, 33, 42)

        authRepository = FxaAuthRepository(TokenStore(applicationContext))

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.rgb(11, 33, 42))
        }
        ViewCompat.setOnApplyWindowInsetsListener(root) { view, windowInsets ->
            val safeArea = windowInsets.getInsets(
                WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout(),
            )
            view.setPadding(safeArea.left, safeArea.top, safeArea.right, safeArea.bottom)
            windowInsets
        }
        val toolbar = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(12), dp(8), dp(12), dp(8))
        }
        val title = TextView(this).apply {
            text = "Sign in with Firefox"
            textSize = 18f
            setTextColor(Color.WHITE)
            layoutParams = LinearLayout.LayoutParams(0, dp(48), 1f)
            gravity = Gravity.CENTER_VERTICAL
        }
        val close = Button(this).apply {
            text = "Cancel"
            setOnClickListener { cancelLogin() }
        }
        toolbar.addView(title)
        toolbar.addView(close)
        root.addView(toolbar)

        progress = ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal).apply {
            max = 100
            visibility = ProgressBar.VISIBLE
        }
        root.addView(progress, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp(3)))

        status = TextView(this).apply {
            text = "Sign in with your Firefox account email and password."
            textSize = 13f
            setTextColor(Color.LTGRAY)
            setPadding(dp(16), dp(10), dp(16), dp(10))
        }
        root.addView(status)

        webView = WebView(this).apply {
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.loadWithOverviewMode = true
            settings.useWideViewPort = true
            settings.allowFileAccess = false
            settings.allowContentAccess = false
            settings.userAgentString = FIREFOX_ANDROID_UA

            val cookieManager = CookieManager.getInstance()
            cookieManager.setAcceptCookie(true)
            cookieManager.setAcceptThirdPartyCookies(this, true)

            val b = WebChannelBridge(
                this,
                authRepository,
                onTokens = ::onTokensCaptured,
                onSessionToken = ::onSessionCaptured,
            )
            bridge = b
            addJavascriptInterface(b, "foxyWebChannel")
            // Also alias harmoneyFxa for backward compatibility
            addJavascriptInterface(b, "harmoneyFxa")

            webChromeClient = object : WebChromeClient() {
                override fun onProgressChanged(view: WebView?, newProgress: Int) {
                    this@FirefoxBrowserLoginActivity.progress.progress = newProgress
                    this@FirefoxBrowserLoginActivity.progress.visibility =
                        if (newProgress >= 100) ProgressBar.GONE else ProgressBar.VISIBLE
                }
            }

            webViewClient = object : WebViewClient() {
                override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
                    val scheme = request.url.scheme?.lowercase().orEmpty()
                    if (scheme != "http" && scheme != "https") return false
                    val host = request.url.host?.lowercase().orEmpty()
                    if (host == "accounts.firefox.com" ||
                        host.endsWith(".firefox.com") ||
                        host == "mozilla.org" ||
                        host.endsWith(".mozilla.org")
                    ) {
                        return false
                    }
                    runCatching {
                        val intent = Intent(Intent.ACTION_VIEW, request.url).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        view.context.startActivity(intent)
                    }
                    return true
                }

                override fun doUpdateVisitedHistory(view: WebView, url: String?, isReload: Boolean) {
                    super.doUpdateVisitedHistory(view, url, isReload)
                    if (isSuccessUrl(url)) bridge?.onSessionVerified()
                }

                override fun onPageStarted(view: WebView, url: String?, favicon: android.graphics.Bitmap?) {
                    super.onPageStarted(view, url, favicon)
                    if (isSuccessUrl(url)) bridge?.onSessionVerified()
                    runCatching { view.evaluateJavascript(WEBCHANNEL_HOOK_JS, null) }
                }

                override fun onPageFinished(view: WebView, url: String?) {
                    super.onPageFinished(view, url)
                    try {
                        CookieManager.getInstance().flush()
                        ControlPlaneHttp.cookieJar.syncFromWebView()
                    } catch (_: Exception) {}
                    if (isSuccessUrl(url)) bridge?.onSessionVerified()
                    try { view.evaluateJavascript(WEBCHANNEL_HOOK_JS, null) } catch (_: Exception) {}
                }
            }
        }
        root.addView(webView, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        setContentView(root)
        ViewCompat.requestApplyInsets(root)
        webView.loadUrl(LOGIN_URL)
    }

    private fun onTokensCaptured(accessToken: String, refreshToken: String?, expiresIn: Long) {
        if (completing || isFinishing) return
        completing = true
        status.text = "Finishing Firefox sign-in…"
        progress.visibility = ProgressBar.VISIBLE
        activityScope.launch {
            runCatching {
                withContext(Dispatchers.IO) {
                    authRepository.completeBrowserLoginWithTokens(accessToken, refreshToken, expiresIn)
                }
            }.onSuccess {
                setResult(RESULT_OK)
                finish()
            }.onFailure { error ->
                completing = false
                status.text = error.message ?: "Firefox sign-in could not be completed."
                AppLogger.w(LOGIN_TAG, "could not save tokens", error)
            }
        }
    }

    private fun onSessionCaptured(token: String) {
        if (completing || isFinishing) return
        completing = true
        status.text = "Finishing Firefox sign-in…"
        progress.visibility = ProgressBar.VISIBLE
        activityScope.launch {
            runCatching {
                withContext(Dispatchers.IO) {
                    authRepository.completeBrowserLogin(token)
                }
            }.onSuccess {
                setResult(RESULT_OK)
                finish()
            }.onFailure { error ->
                completing = false
                status.text = error.message ?: "Firefox sign-in could not be completed."
                AppLogger.w(LOGIN_TAG, "could not finish browser sign-in", error)
            }
        }
    }

    override fun onBackPressed() {
        if (!completing && ::webView.isInitialized && webView.canGoBack()) {
            webView.goBack()
        } else if (!completing) {
            cancelLogin()
        }
    }

    private fun cancelLogin() {
        if (completing) return
        setResult(RESULT_CANCELED)
        finish()
    }

    override fun onDestroy() {
        if (::webView.isInitialized) {
            webView.stopLoading()
            webView.removeJavascriptInterface("foxyWebChannel")
            webView.removeJavascriptInterface("harmoneyFxa")
            webView.destroy()
        }
        bridge = null
        activityScope.cancel()
        super.onDestroy()
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

    private fun isSuccessUrl(url: String?): Boolean {
        if (url.isNullOrBlank()) return false
        val u = url.lowercase()
        return u.contains("confirmed") ||
            u.contains("/connect_another_device") ||
            u.contains("/pair") ||
            u.contains("/settings") ||
            u.contains("/complete") ||
            u.contains("/verified") ||
            u.contains("success")
    }
}

internal class WebChannelBridge(
    webView: WebView,
    private val authRepository: FxaAuthRepository,
    private val onTokens: (String, String?, Long) -> Unit,
    private val onSessionToken: (String) -> Unit,
) {
    private val webViewRef = WeakReference(webView)
    @Volatile
    var pendingSessionToken: String? = null
        private set
    @Volatile
    private var exchangeInProgress = false

    @JavascriptInterface
    fun onMessage(payload: String) {
        onMessage(payload, "https://accounts.firefox.com")
    }

    @JavascriptInterface
    fun onSessionVerified() {
        val token = pendingSessionToken ?: return
        exchangeInProgress = false
        notifySessionToken(token)
    }

    @JavascriptInterface
    fun onOAuthResult(status: Int, responseText: String) {
        val token = pendingSessionToken
        if (status in 200..299) {
            val parsed = runCatching {
                val json = JSONObject(responseText)
                val accessToken = json.getString("access_token")
                val refreshToken = json.optString("refresh_token").ifBlank { null }
                val expiresIn = json.optLong("expires_in", 0L)
                Triple(accessToken, refreshToken, expiresIn)
            }.getOrNull()
            if (parsed != null) {
                val view = webViewRef.get()
                if (view != null) {
                    view.post { onTokens(parsed.first, parsed.second, parsed.third) }
                } else {
                    onTokens(parsed.first, parsed.second, parsed.third)
                }
                return
            }
        }
        val isUnconfirmed = status == 400 &&
            (responseText.contains("104") ||
                responseText.contains("Unconfirmed session", ignoreCase = true) ||
                responseText.contains("unverified", ignoreCase = true))
        if (isUnconfirmed) {
            exchangeInProgress = false
            return
        }
        if (token != null) {
            fallbackSession(token)
        }
    }

    @JavascriptInterface
    fun onOAuthError(error: String) {
        AppLogger.w(LOGIN_TAG, "in-browser oauth exchange failed: $error")
        val token = pendingSessionToken
        if (token != null) {
            fallbackSession(token)
        }
    }

    private fun fallbackSession(token: String) {
        exchangeInProgress = false
        val view = webViewRef.get()
        if (view != null) {
            view.post { onSessionToken(token) }
        } else {
            onSessionToken(token)
        }
    }

    @JavascriptInterface
    fun onMessage(payload: String, originUrl: String) {
        val host = runCatching { Uri.parse(originUrl).host?.lowercase() }.getOrNull()
        if (host != "accounts.firefox.com" && host?.endsWith(".firefox.com") != true) {
            return
        }
        val message = runCatching {
            JSONObject(payload).optJSONObject("message") ?: JSONObject()
        }.getOrNull() ?: return
        val command = message.optString("command")
        val data = message.optJSONObject("data") ?: JSONObject()
        val messageId = message.optString("messageId")

        when (command) {
            CMD_FXA_STATUS -> reply(
                messageId,
                CMD_FXA_STATUS,
                """{"capabilities":{},"signedInUser":null}""",
            )
            CMD_CAN_LINK_ACCOUNT -> reply(
                messageId,
                CMD_CAN_LINK_ACCOUNT,
                """{"ok":true}""",
            )
            CMD_LOGIN, "fxaccounts:oauth_login" -> {
                val token = data.optString("sessionToken", "").trim()
                    .ifBlank { data.optString("token", "").trim() }
                if (SESSION_TOKEN_HEX.matches(token)) {
                    pendingSessionToken = token
                    val hasVerificationReason = data.has("verificationReason") &&
                        data.optString("verificationReason").isNotBlank()
                    val isVerified = if (data.has("verified")) {
                        data.optBoolean("verified", true)
                    } else {
                        !hasVerificationReason
                    }
                    if (isVerified && !hasVerificationReason) {
                        notifySessionToken(token)
                    }
                }
                if (messageId.isNotBlank()) {
                    reply(messageId, command, """{"ok":true}""")
                }
            }
            else -> {
                if (command.contains("verified", ignoreCase = true)) {
                    val token = data.optString("sessionToken", "").trim()
                        .ifBlank { data.optString("token", "").trim() }
                        .ifBlank { pendingSessionToken ?: "" }
                    if (SESSION_TOKEN_HEX.matches(token)) {
                        pendingSessionToken = token
                        exchangeInProgress = false
                        notifySessionToken(token)
                    }
                }
                if (messageId.isNotBlank()) {
                    reply(messageId, command, """{"ok":true}""")
                }
            }
        }
    }

    fun notifySessionToken(token: String) {
        if (!SESSION_TOKEN_HEX.matches(token)) return
        if (exchangeInProgress) return
        exchangeInProgress = true
        pendingSessionToken = token
        try {
            CookieManager.getInstance().flush()
            ControlPlaneHttp.cookieJar.syncFromWebView()
        } catch (_: Exception) {}
        val hawkInfo = runCatching { authRepository.buildOAuthHawkHeader(token) }.getOrNull()
        val view = webViewRef.get()
        if (hawkInfo == null || view == null) {
            fallbackSession(token)
            return
        }
        val (hawkHeader, bodyJson) = hawkInfo
        val script = """
            (function() {
              fetch('https://api.accounts.firefox.com/v1/oauth/token', {
                method: 'POST',
                headers: {
                  'Authorization': ${jsString(hawkHeader)},
                  'Content-Type': 'application/json'
                },
                body: ${jsString(bodyJson)}
              }).then(function(res) {
                return res.text().then(function(text) {
                  foxyWebChannel.onOAuthResult(res.status, text);
                });
              }).catch(function(err) {
                foxyWebChannel.onOAuthError(err ? (err.message || ('' + err)) : 'fetch_failed');
              });
            })();
        """.trimIndent()
        view.post {
            runCatching { view.evaluateJavascript(script, null) }
                .onFailure {
                    fallbackSession(token)
                }
        }
    }

    private fun reply(messageId: String, command: String, dataJson: String) {
        val view = webViewRef.get() ?: return
        val script = "window.__foxyReply && window.__foxyReply(" +
            "${jsString(FXA_CHANNEL_ID)}, ${jsString(messageId)}, ${jsString(command)}, ${jsString(dataJson)});"
        view.post {
            runCatching { view.evaluateJavascript(script, null) }
                .onFailure { AppLogger.w(LOGIN_TAG, "could not answer webchannel command $command", it) }
        }
    }
}
