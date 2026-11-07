package io.harmoney.client

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.harmoney.client.firefox.data.FxaAuthRepository
import io.harmoney.client.firefox.data.GuardianClient
import io.harmoney.client.firefox.data.ProxyStateStore
import io.harmoney.client.firefox.data.ServerListClient
import io.harmoney.client.firefox.data.TokenStore
import io.harmoney.client.firefox.vpn.FoxyVpnService
import io.harmoney.client.firefox.vpn.upstream.NettyLoggingBridge
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.conscrypt.Conscrypt
import java.security.Security
import java.time.Instant

class FirefoxVpnBridge(private val context: Context, private val activity: Activity) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private val tokenStore = TokenStore(context)
    private val auth = FxaAuthRepository(tokenStore)
    private var pendingBrowserLoginResult: MethodChannel.Result? = null

    companion object {
        const val BROWSER_LOGIN_REQUEST_CODE = 4105
    }

    init {
        NettyLoggingBridge.install()
        runCatching { Security.insertProviderAt(Conscrypt.newProvider(), 1) }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.getSystemService(NotificationManager::class.java)?.createNotificationChannel(
                NotificationChannel("harmoney_firefox_vpn", "Firefox VPN", NotificationManager.IMPORTANCE_LOW),
            )
        }
    }

    fun handle(call: MethodCall, result: MethodChannel.Result): Boolean {
        when (call.method) {
            // Connecting only needs local sign-in state. The service renews an
            // expired token after selecting/protecting the physical network.
            // Fetching quota here can stall every connect on a blocked API.
            "firefoxSessionState" -> result.success(mapOf("logged_in" to (tokenStore.loadAuth() != null)))
            "firefoxAccountState" -> async(result) {
                val stored = tokenStore.loadAuth()
                if (stored == null) return@async mapOf("logged_in" to false)
                val current = if (tokenStore.hasValidSession()) stored else auth.refreshAccessToken()
                val entitlement = current?.let {
                    runCatching { GuardianClient().fetchUserInfo("https://vpn.mozilla.org", it.accessToken) }.getOrNull()
                }
                mapOf(
                    "logged_in" to (current != null),
                    "quota" to entitlement?.let {
                        mapOf(
                            "limit" to it.maxBytes,
                            "remaining" to it.quotaRemaining,
                            "reset" to it.quotaReset?.let(Instant::ofEpochSecond)?.toString(),
                        )
                    },
                )
            }
            "firefoxLogin" -> if (call.argument<Boolean>("browser") == true) {
                startBrowserLogin(result)
            } else async(result) {
                val code = call.argument<String>("code")
                val needsCode = if (code.isNullOrBlank()) {
                    val email = call.argument<String>("email")?.trim().orEmpty()
                    val password = call.argument<String>("password").orEmpty()
                    require(email.isNotEmpty() && password.isNotEmpty()) { "Email and password are required" }
                    auth.startLogin(email, password).getOrThrow()
                } else {
                    auth.submitTwoFactorCode(code.trim()).getOrThrow()
                }
                if (needsCode) throw FirefoxVerificationRequired()
                null
            }
            "firefoxLogout" -> async(result) { tokenStore.clear(); ProxyStateStore(context).clear(); null }
            "firefoxLocations" -> async(result) {
                // Match FireTunnelVpnCore.locationSnapshot(): country -> city -> server.
                // Returning a flat server list makes Flutter silently produce zero locations.
                val locations = ServerListClient(context).fetchCountries().map { country ->
                    mapOf(
                        "code" to country.code,
                        "name" to country.name,
                        "cities" to country.cities.map { city ->
                            mapOf(
                                "code" to city.code,
                                "name" to city.name,
                                "servers" to city.servers.mapNotNull { server ->
                                    val target = ServerListClient.defaultConnectTarget(server)
                                        ?: return@mapNotNull null
                                    mapOf(
                                        "hostname" to target.first,
                                        "port" to target.second,
                                        "quarantined" to server.quarantined,
                                    )
                                },
                            )
                        },
                    )
                }
                mapOf("locations" to locations, "source" to "Mozilla Remote Settings")
            }
            "firefoxConnect" -> async(result) {
                check(tokenStore.loadAuth() != null) { "authentication_required" }
                val countryCode = call.argument<String>("countryCode").orEmpty()
                val cityCode = call.argument<String>("cityCode").orEmpty()
                val host = call.argument<String>("hostname").orEmpty()
                val port = call.argument<Int>("port") ?: 2499
                require(countryCode.matches(Regex("[A-Za-z]{2,3}"))) { "Invalid country" }
                require(host.length in 1..253 && host.matches(Regex("[A-Za-z0-9.-]+"))) { "Invalid endpoint" }
                require(port in 1..65535) { "Invalid port" }
                ProxyStateStore(context).save(
                    io.harmoney.client.firefox.data.model.ProxyCandidate(
                        host, port, countryCode, call.argument<String>("country").orEmpty(), cityCode,
                    ),
                )
                FoxyVpnService.start(context)
                null
            }
            "firefoxDisconnect" -> { FoxyVpnService.stop(context); result.success(null) }
            "firefoxStatus" -> {
                val candidate = ProxyStateStore(context).load()
                result.success(
                mapOf(
                    "state" to if (FoxyVpnService.state.value.name == "DISCONNECTED" &&
                        !FoxyVpnService.lastError.value.isNullOrBlank()) "error"
                        else FoxyVpnService.state.value.name.lowercase(),
                    "message" to FoxyVpnService.lastError.value,
                    "error" to FoxyVpnService.lastError.value,
                    "country_code" to candidate?.countryCode,
                    "country" to candidate?.countryName,
                    "location" to candidate?.cityCode,
                    "endpoint" to candidate?.authority,
                    "transport" to "HTTP/2",
                    "protocol" to if (FoxyVpnService.state.value.name == "DISCONNECTED") null else "firefox",
                ),
                )
            }
            else -> return false
        }
        return true
    }

    fun permissionGranted(): Boolean = VpnService.prepare(context) == null

    private fun startBrowserLogin(result: MethodChannel.Result) {
        if (pendingBrowserLoginResult != null) {
            result.error("login_in_progress", "Firefox sign-in is already open", null)
            return
        }
        pendingBrowserLoginResult = result
        runCatching {
            activity.startActivityForResult(
                Intent(activity, FirefoxBrowserLoginActivity::class.java),
                BROWSER_LOGIN_REQUEST_CODE,
            )
        }.onFailure { error ->
            pendingBrowserLoginResult = null
            result.error("browser_login_unavailable", error.message, null)
        }
    }

    fun onBrowserLoginResult(resultCode: Int) {
        val result = pendingBrowserLoginResult ?: return
        pendingBrowserLoginResult = null
        result.success(mapOf("ok" to (resultCode == Activity.RESULT_OK)))
    }

    private fun async(result: MethodChannel.Result, block: suspend () -> Any?) {
        scope.launch {
            runCatching { withContext(Dispatchers.IO) { block() } }
                .onSuccess(result::success)
                .onFailure {
                    val code = if (it is FirefoxVerificationRequired) "verification_required" else "firefox_failed"
                    result.error(code, it.message ?: code, null)
                }
        }
    }
}

private class FirefoxVerificationRequired : Exception("verification_required")
