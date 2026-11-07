package io.harmoney.client

import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.TrafficStats
import android.os.Build
import android.os.Process
import java.io.File
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.Socket
import java.time.LocalDate
import java.time.YearMonth
import org.json.JSONObject

internal object AndroidNetworkFeatures {
    private const val PREFS = "vpn_traffic_ledger"

    fun probeVpnDataPath(context: Context): Map<String, Any?> {
        val cm = context.getSystemService(ConnectivityManager::class.java)
        val vpn = cm.allNetworks.firstOrNull { network ->
            cm.getNetworkCapabilities(network)?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true
        } ?: error("VPN network unavailable")
        val client = okhttp3.OkHttpClient.Builder().socketFactory(vpn.socketFactory)
            .dns(object : okhttp3.Dns {
                override fun lookup(hostname: String): List<InetAddress> = vpn.getAllByName(hostname).toList()
            }).followRedirects(false).followSslRedirects(false)
            .connectTimeout(6, java.util.concurrent.TimeUnit.SECONDS)
            .callTimeout(8, java.util.concurrent.TimeUnit.SECONDS).build()
        return probeHttps(client)
    }

    fun probeFirefoxDataPath(context: Context): Map<String, Any?> {
        check(io.harmoney.client.firefox.vpn.FoxyVpnService.state.value.name == "CONNECTED") {
            "Firefox tunnel unavailable"
        }
        // Firefox excludes its own UID from the VPN. Test through its local
        // SOCKS -> HTTP/2 data plane, rather than binding an excluded UID to TUN.
        val port = io.harmoney.client.firefox.data.SettingsStore(context).socksPort
        val client = okhttp3.OkHttpClient.Builder()
            .proxy(java.net.Proxy(java.net.Proxy.Type.SOCKS, InetSocketAddress("127.0.0.1", port)))
            .followRedirects(false).followSslRedirects(false)
            .connectTimeout(6, java.util.concurrent.TimeUnit.SECONDS)
            .callTimeout(8, java.util.concurrent.TimeUnit.SECONDS).build()
        return probeHttps(client)
    }

    private fun probeHttps(client: okhttp3.OkHttpClient): Map<String, Any?> {
        try {
            for (url in listOf("https://cloudflare.com/cdn-cgi/trace",
                "https://www.gstatic.com/generate_204",
                "https://www.msftconnecttest.com/connecttest.txt")) {
                val started = System.nanoTime()
                val valid = runCatching {
                    client.newCall(okhttp3.Request.Builder().url(url)
                        .header("Cache-Control", "no-cache").build()).execute().use { response ->
                        val body = response.body?.string() ?: ""
                        when {
                            url.contains("cdn-cgi/trace") -> response.code == 200 &&
                                body.contains("ip=") && body.contains("colo=")
                            url.contains("generate_204") -> response.code == 204 && body.isEmpty()
                            else -> response.code == 200 && body.trim() == "Microsoft Connect Test"
                        }
                    }
                }.getOrDefault(false)
                if (valid) return mapOf("latencyMs" to
                    ((System.nanoTime() - started) / 1_000_000).coerceAtLeast(1))
            }
            error("VPN tunnel did not return a verified HTTPS connectivity response")
        } finally {
            client.connectionPool.evictAll()
            client.dispatcher.executorService.shutdown()
        }
    }

    fun trafficSnapshot(context: Context): Map<String, Any> {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val connected = isVpnConnected(context)
        val rx = TrafficStats.getUidRxBytes(Process.myUid())
        val tx = TrafficStats.getUidTxBytes(Process.myUid())
        val safeRx = rx.coerceAtLeast(0)
        val safeTx = tx.coerceAtLeast(0)
        val source = "vpn-app-uid"
        val today = LocalDate.now().toString()
        val month = YearMonth.now().toString()
        val previousSource = prefs.getString("source", source)
        val previousRx = prefs.getLong("last_rx", safeRx)
        val previousTx = prefs.getLong("last_tx", safeTx)
        val deltaRx = if (connected && previousSource == source) (safeRx - previousRx).coerceAtLeast(0) else 0
        val deltaTx = if (connected && previousSource == source) (safeTx - previousTx).coerceAtLeast(0) else 0
        val dayRx = (if (prefs.getString("day", today) == today) prefs.getLong("day_rx", 0) else 0) + deltaRx
        val dayTx = (if (prefs.getString("day", today) == today) prefs.getLong("day_tx", 0) else 0) + deltaTx
        val monthRx = (if (prefs.getString("month", month) == month) prefs.getLong("month_rx", 0) else 0) + deltaRx
        val monthTx = (if (prefs.getString("month", month) == month) prefs.getLong("month_tx", 0) else 0) + deltaTx
        prefs.edit()
            .putString("source", source).putLong("last_rx", safeRx).putLong("last_tx", safeTx)
            .putString("day", today).putLong("day_rx", dayRx).putLong("day_tx", dayTx)
            .putString("month", month).putLong("month_rx", monthRx).putLong("month_tx", monthTx)
            .apply()
        return mapOf(
            "connected" to connected,
            "rx_bytes" to safeRx,
            "tx_bytes" to safeTx,
            "rx_bps" to 0,
            "tx_bps" to 0,
            "day_rx_bytes" to dayRx,
            "day_tx_bytes" to dayTx,
            "month_rx_bytes" to monthRx,
            "month_tx_bytes" to monthTx,
            "all_rx_bytes" to safeRx,
            "all_tx_bytes" to safeTx,
            "source" to source,
        )
    }

    fun diagnostics(context: Context): Map<String, Any?> {
        val cm = context.getSystemService(ConnectivityManager::class.java)
        val network = cm.activeNetwork
        val capabilities = network?.let(cm::getNetworkCapabilities)
        val links = network?.let(cm::getLinkProperties)
        val physical = runCatching { AndroidLatencyProbes.physicalNetwork(context) }.getOrNull()
        return mapOf(
            "platform" to "android",
            "physical_network" to physical?.networkHandle?.toString(),
            "vpn_transport" to (capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true),
            "internet_capability" to (capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true),
            "validated" to (capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED) == true),
            "metered" to cm.isActiveNetworkMetered,
            "interface" to links?.interfaceName,
            "mtu" to links?.mtu,
            "dns_servers" to (links?.dnsServers?.map { it.hostAddress } ?: emptyList<String>()),
            "routes" to (links?.routes?.map { it.toString() } ?: emptyList<String>()),
            "private_dns_active" to links?.isPrivateDnsActive,
            "private_dns_server" to links?.privateDnsServerName,
            "protocol" to MobileVpnRuntimeState.activeProtocol(),
            "runtime_state" to MobileVpnRuntimeState.currentState(),
        )
    }

    fun testInternet(): Map<String, Any?> {
        val targets = listOf("1.1.1.1" to 53, "8.8.8.8" to 53)
        for ((host, port) in targets) {
            val start = System.currentTimeMillis()
            try {
                Socket().use { socket ->
                    socket.connect(InetSocketAddress(host, port), 3000)
                }
                val duration = System.currentTimeMillis() - start
                return mapOf("success" to true, "target" to "$host:$port", "latencyMs" to duration, "message" to "Connected in ${duration}ms")
            } catch (e: Exception) {
                // try next
            }
        }
        return mapOf("success" to false, "message" to "Failed to connect to public DNS test IP addresses.")
    }

    fun testDns(): Map<String, Any?> {
        val domains = listOf("cloudflare.com", "google.com")
        val results = mutableMapOf<String, List<String>>()
        var resolvedAny = false
        for (domain in domains) {
            try {
                val addrs = InetAddress.getAllByName(domain).map { it.hostAddress }
                if (addrs.isNotEmpty()) {
                    results[domain] = addrs
                    resolvedAny = true
                }
            } catch (e: Exception) {
                results[domain] = listOf("Resolution error: ${e.message}")
            }
        }
        return mapOf("success" to resolvedAny, "resolutions" to results)
    }

    fun testServer(hostname: String): Map<String, Any?> {
        val start = System.currentTimeMillis()
        return try {
            Socket().use { socket ->
                socket.connect(InetSocketAddress(hostname, 443), 4000)
            }
            val duration = System.currentTimeMillis() - start
            mapOf("success" to true, "hostname" to hostname, "latencyMs" to duration, "message" to "Server reachable in ${duration}ms")
        } catch (e: Exception) {
            mapOf("success" to false, "hostname" to hostname, "message" to (e.message ?: "Server unreachable"))
        }
    }

    fun isVpnConnected(context: Context): Boolean {
        val cm = context.getSystemService(ConnectivityManager::class.java)
        return cm?.allNetworks?.any { network ->
            cm.getNetworkCapabilities(network)?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true
        } == true
    }
}
