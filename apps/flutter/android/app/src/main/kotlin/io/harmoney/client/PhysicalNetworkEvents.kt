package io.harmoney.client

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/** Tracks actual network identity, including cellular-to-cellular SIM changes. */
internal class PhysicalNetworkEvents(private val context: Context) : EventChannel.StreamHandler {
    private val cm = context.getSystemService(ConnectivityManager::class.java)
    private val handler = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null
    private var previous: String? = null
    private var registered = false
    private val publish = Runnable {
        val identity = runCatching {
            AndroidLatencyProbes.physicalNetwork(context).networkHandle.toString()
        }.getOrDefault("unavailable")
        if (identity != previous) {
            previous = identity
            sink?.success(identity)
        }
    }
    private fun changed() {
        handler.removeCallbacks(publish)
        handler.postDelayed(publish, 200)
    }
    private val callback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) = changed()
        override fun onLost(network: Network) = changed()
        override fun onCapabilitiesChanged(network: Network, capabilities: NetworkCapabilities) = changed()
    }
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        previous = null
        if (!registered) {
            cm.registerNetworkCallback(NetworkRequest.Builder()
                .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                .addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN).build(), callback)
            registered = true
        }
        changed()
    }
    override fun onCancel(arguments: Any?) = close()
    fun close() {
        sink = null
        handler.removeCallbacks(publish)
        if (registered) runCatching { cm.unregisterNetworkCallback(callback) }
        registered = false
    }
}
