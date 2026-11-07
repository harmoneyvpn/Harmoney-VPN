package io.harmoney.client

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.*
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import okhttp3.OkHttpClient
import okhttp3.Request
import java.net.InetSocketAddress
import java.net.Proxy
import java.util.concurrent.TimeUnit
import io.harmoney.client.firefox.data.SettingsStore

class HarmoneyVpnService : VpnService() {
    companion object {
        const val START = "net.harmoney.vpn.START"
        const val STOP = "net.harmoney.vpn.STOP"
        private const val CHANNEL = "harmoney_vpn"
        private const val NOTICE = 7101
        @Volatile var status = "disconnected"; private set
        @Volatile var lastError: String? = null; private set
        @Volatile var trafficVerified = false; private set
        @Volatile var tunnelRunning = false; private set
        @Volatile var egressCountry = ""; private set
        @Volatile var egressIp = ""; private set
        @Volatile var connectedAtEpochMs = 0L; private set
        @Volatile private var verifiedAt = 0L
        @Volatile var onStatus: ((Map<String, Any?>) -> Unit)? = null
        private val engineOperations = Mutex()
        fun gatewayVerified() = tunnelRunning && trafficVerified &&
            android.os.SystemClock.elapsedRealtime() - verifiedAt < 45_000
    }
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val operations = engineOperations
    private var session: Job? = null
    private var descriptor: ParcelFileDescriptor? = null
    @Volatile private var generation = 0
    private var coreStarted = false
    private val probeClient = OkHttpClient.Builder()
        .proxy(Proxy(Proxy.Type.SOCKS, InetSocketAddress("127.0.0.1", 5000)))
        .connectTimeout(4, TimeUnit.SECONDS).readTimeout(5, TimeUnit.SECONDS)
        .callTimeout(8, TimeUnit.SECONDS).build()

    override fun onCreate() {
        super.onCreate()
        getSystemService(NotificationManager::class.java).createNotificationChannel(
            NotificationChannel(CHANNEL, "Harmoney VPN", NotificationManager.IMPORTANCE_LOW)
                .apply { setShowBadge(false) })
    }

    private fun notification(text: String) = NotificationCompat.Builder(this, CHANNEL)
        .setSmallIcon(R.drawable.ic_stat_harmoney)
        .setContentTitle("Harmoney VPN").setContentText(VpnNotificationLocalizer.text(this, text))
        .setWhen(connectedAtEpochMs.takeIf { status == "connected" } ?: System.currentTimeMillis())
        .setUsesChronometer(status == "connected")
        .setOngoing(true).setOnlyAlertOnce(true).setSilent(true)
        .setCategory(NotificationCompat.CATEGORY_SERVICE)
        .setContentIntent(PendingIntent.getActivity(this, 0,
            Intent(this, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT))
        .addAction(0, VpnNotificationLocalizer.disconnect(this), PendingIntent.getService(this, 1,
            Intent(this, HarmoneyVpnService::class.java).setAction(STOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)).build()

    private fun publish(value: String, text: String, error: String? = null) {
        if (value == "connected" && status != "connected") {
            connectedAtEpochMs = System.currentTimeMillis()
        } else if (value == "disconnected" || value == "failed") {
            connectedAtEpochMs = 0L
        }
        status = value
        trafficVerified = value == "connected"
        if (trafficVerified) verifiedAt = android.os.SystemClock.elapsedRealtime()
        lastError = error
        onStatus?.invoke(mapOf("status" to value, "error" to error))
        getSystemService(NotificationManager::class.java).notify(NOTICE, notification(text))
        VpnTileService.updateTile(this)
        HarmoneyWidgetProvider.refresh(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == STOP || intent == null) {
            shutdown()
            return START_NOT_STICKY
        }
        if (intent.action != START) return START_NOT_STICKY
        val notice = notification("در حال اتصال / Connecting…")
        if (Build.VERSION.SDK_INT >= 34) startForeground(NOTICE, notice, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        else startForeground(NOTICE, notice)
        val pattern = intent.getStringExtra("pattern") ?: "auto"
        val current = ++generation
        // Clear a previous failure synchronously, before waiting for old native
        // cleanup. Callers must not mistake the old session for this attempt.
        publish("connecting", "در حال پیدا کردن مسیر / Finding a route…")
        session?.cancel()
        session = scope.launch {
            operations.withLock {
                cleanup()
                if (current != generation) return@withLock
                try {
                    publish("connecting", "در حال پیدا کردن مسیر / Finding a route…")
                    val activeFlow = java.io.File(filesDir, "harmoney_flowline_active.json")
                    val suppliedFlow = intent?.getStringExtra("flowLine")?.takeIf { it.isNotBlank() }
                    val source = if (suppliedFlow != null) {
                        runCatching {
                            org.json.JSONObject(suppliedFlow)
                            suppliedFlow
                        }.getOrElse {
                            assets.open("flutter_assets/assets/config/harmoney_flowline.json")
                                .bufferedReader().use { it.readText() }
                        }
                    } else if (activeFlow.exists() && activeFlow.length() > 0) {
                        runCatching {
                            val text = activeFlow.readText()
                            org.json.JSONObject(text)
                            text
                        }.getOrElse {
                            assets.open("flutter_assets/assets/config/harmoney_flowline.json")
                                .bufferedReader().use { it.readText() }
                        }
                    } else {
                        assets.open("flutter_assets/assets/config/harmoney_flowline.json")
                            .bufferedReader().use { it.readText() }
                    }
                    val physical = AndroidLatencyProbes.physicalNetwork(this@HarmoneyVpnService)
                    val cellular = getSystemService(android.net.ConnectivityManager::class.java)
                        .getNetworkCapabilities(physical)?.hasTransport(android.net.NetworkCapabilities.TRANSPORT_CELLULAR) == true
                    val routes = HarmoneyRouteConfig.plan(source, pattern, cellular)
                    var verified = false
                    for (route in routes) {
                        ensureActive()
                        check(current == generation) { "Harmoney connection was cancelled" }
                        cleanup()
                        publish("connecting", "در حال بررسی مسیر / Checking route: $route")
                        val (flow, labels) = HarmoneyRouteConfig.select(source, route)
                        val digest = java.security.MessageDigest.getInstance("SHA-256")
                            .digest(flow.toByteArray()).take(6).joinToString("") { "%02x".format(it) }
                        // Xray route choices are per SIM/source revision. Cloudflare
                        // device registrations remain durable across networks.
                        val cache = java.io.File(filesDir,
                            HarmoneyRouteConfig.cacheName(route, physical.networkHandle.toString(), digest))
                            .apply { mkdirs() }
                        HarmoneyEngine.invoke(this@HarmoneyVpnService, "setCacheDir", cache.absolutePath)
                        coreStarted = true
                        HarmoneyEngine.invoke(this@HarmoneyVpnService, "startVPN", cache.absolutePath, flow, labels, false, true)
                        val isSelectedSubscription = source.contains("\"key\":\"personal-sub-")
                        val connectWindowMs = when {
                            pattern == "auto" -> 40_000L
                            isSelectedSubscription -> 45_000L
                            else -> 90_000L
                        }
                        val deadline = android.os.SystemClock.elapsedRealtime() + connectWindowMs
                        while (true) {
                            ensureActive()
                            if (verifyProxy()) { verified = true; break }
                            if (android.os.SystemClock.elapsedRealtime() >= deadline) break
                            delay(1000)
                        }
                        if (verified) break
                        AndroidEventLogger.warn("HarmoneyEngine", "ROUTE_TIMEOUT",
                            "Route $route did not verify on network ${physical.networkHandle}", protocol = "harmoney")
                    }
                    check(verified) { "TIMEOUT: No working Harmoney route was found on this network" }
                    ensureActive()
                    publish("verifying", "در حال بررسی تونل / Verifying tunnel…")
                    // DXcore has no protect-socket callback. Its own app UID is
                    // excluded, as in upstream, while other apps use the TUN.
                    val builder = Builder().setSession("Harmoney")
                        .addAddress("10.0.0.2", 32)
                        .addDnsServer("1.1.1.1").setMtu(1280).setBlocking(true)
                        .addDisallowedApplication(packageName)
                        .setUnderlyingNetworks(arrayOf(physical))
                    val bypassManager = CountryBypassRuleManager.getInstance(this@HarmoneyVpnService)
                    val bypassIpv4 = if (bypassManager.hasActiveBypassRoutes()) {
                        bypassManager.getActiveBypassedIpv4Cidrs()
                    } else {
                        emptyList()
                    }
                    if (bypassIpv4.isEmpty()) {
                        builder.addRoute("0.0.0.0", 0)
                    } else if (Build.VERSION.SDK_INT >= 33) {
                        builder.addRoute("0.0.0.0", 0)
                        for (cidr in bypassIpv4) {
                            val (address, prefixText) = cidr.split('/', limit = 2)
                            val prefix = prefixText.toIntOrNull()
                                ?: error("Invalid country-bypass prefix")
                            builder.excludeRoute(android.net.IpPrefix(
                                java.net.InetAddress.getByName(address), prefix,
                            ))
                        }
                    } else {
                        val complement = bypassManager.calculateComplementRoutesIpv4(bypassIpv4)
                        check(complement.size <= 4096) {
                            "Too many country-bypass routes for this Android version"
                        }
                        for ((address, prefix) in complement) {
                            builder.addRoute(address, prefix)
                        }
                    }
                    val excludedApps = SettingsStore(this@HarmoneyVpnService).excludedApps
                    for (excludedPackage in excludedApps) {
                        runCatching { builder.addDisallowedApplication(excludedPackage) }
                    }
                    // Without an IPv6 address/route Android blocks that family;
                    // it must never escape directly around this IPv4 core.
                    if (Build.VERSION.SDK_INT >= 29) builder.setMetered(false)
                    descriptor = builder.establish() ?: error("VPN permission was revoked")
                    // Transfer a duplicate to the native engine. The service
                    // keeps its own descriptor; native shutdown may close its FD.
                    val nativeFd = ParcelFileDescriptor.dup(descriptor!!.fileDescriptor).detachFd()
                    check(HarmoneyEngine.invoke(this@HarmoneyVpnService, "startT2S",
                        nativeFd.toLong(), "127.0.0.1:5000") == true) { "Native system tunnel could not start" }
                    tunnelRunning = true
                    var failures = 0
                    while (isActive && current == generation) {
                        if (verifyTunnel()) {
                            failures = 0
                            publish("connected", "متصل؛ مسیر تأیید شد / Connected · verified")
                        } else {
                            failures++
                            check(failures < 3) { "Harmoney tunnel traffic stopped" }
                            publish("recovering", "در حال بازیابی مسیر / Rechecking tunnel…")
                        }
                        delay(10_000)
                    }
                } catch (cancelled: CancellationException) {
                    throw cancelled
                } catch (error: Throwable) {
                    publish("failed", "اتصال ناموفق / Connection failed", error.cause?.message ?: error.message)
                } finally {
                    cleanup()
                    if (current == generation) {
                        stopForeground(STOP_FOREGROUND_REMOVE)
                        stopSelf()
                    }
                }
            }
        }
        return START_NOT_STICKY
    }

    private fun verifyProxy(): Boolean = listOf("https://1.1.1.1/cdn-cgi/trace", "https://www.cloudflare.com/cdn-cgi/trace").any { url ->
        runCatching {
            probeClient.newCall(Request.Builder().url(url).header("Cache-Control", "no-cache").build())
                .execute().use { response ->
                    if (!response.isSuccessful) return@use false
                    val body = response.body?.string().orEmpty()
                    val lines = body.lineSequence().toList()
                    val hasIp = lines.any { it.startsWith("ip=") }
                    if (hasIp) {
                        val locLine = lines.firstOrNull { it.startsWith("loc=") }
                        val ipLine = lines.firstOrNull { it.startsWith("ip=") }
                        if (locLine != null) {
                            val code = locLine.substringAfter("loc=").trim().uppercase()
                            if (code.length == 2 && code.all { it in 'A'..'Z' }) {
                                egressCountry = code
                            }
                        }
                        if (ipLine != null) {
                            egressIp = ipLine.substringAfter("ip=").trim()
                        }
                        true
                    } else {
                        false
                    }
                }
        }.getOrDefault(false)
    }
    // Android forbids an excluded UID from explicitly using the VPN network.
    // Verify the real gateway over SOCKS plus successful native TUN startup;
    // end-to-end traffic from another app still needs device validation.
    private fun verifyTunnel(): Boolean {
        if (!tunnelRunning || descriptor?.fileDescriptor?.valid() != true || !verifyProxy()) return false
        return listOf("https://1.1.1.1/dns-query", "https://cloudflare-dns.com/dns-query",
            "https://dns.google/resolve").any { endpoint -> runCatching {
            val request = Request.Builder()
                .url("$endpoint?name=example.com&type=A")
                .header("Accept", "application/dns-json").build()
            probeClient.newCall(request).execute().use { response ->
                if (!response.isSuccessful) false
                else org.json.JSONObject(response.body?.string() ?: "{}").let { dns ->
                    dns.optInt("Status", -1) == 0 && (dns.optJSONArray("Answer")?.length() ?: 0) > 0
                }
            }
        }.getOrDefault(false) }
    }
    private fun cleanup() {
        tunnelRunning = false
        trafficVerified = false
        verifiedAt = 0
        egressCountry = ""
        egressIp = ""
        if (coreStarted) {
            runCatching { HarmoneyEngine.invoke(this, "stopT2S") }
            runCatching { HarmoneyEngine.invoke(this, "stopVPN") }
        }
        coreStarted = false
        runCatching { descriptor?.close() }
        descriptor = null
    }
    private fun shutdown() {
        val stopGeneration = ++generation
        publish("disconnecting", "در حال قطع اتصال / Disconnecting…")
        session?.cancel()
        scope.launch {
            operations.withLock {
                cleanup()
                if (stopGeneration != generation) return@withLock
                publish("disconnected", "قطع شد / Disconnected")
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
    }
    override fun onRevoke() { shutdown(); super.onRevoke() }
    override fun onDestroy() {
        ++generation
        session?.cancel()
        // Serialize final cleanup with any native call still completing on IO.
        scope.launch {
            operations.withLock { cleanup() }
            scope.cancel()
        }
        super.onDestroy()
    }
}
