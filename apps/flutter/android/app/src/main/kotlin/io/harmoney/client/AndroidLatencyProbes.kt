package io.harmoney.client

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities

/** Finds the physical internet network for the Harmoney Smart tunnel. */
internal object AndroidLatencyProbes {
    fun physicalNetwork(context: Context): Network {
        val manager = context.getSystemService(ConnectivityManager::class.java)
        return manager.allNetworks.firstOrNull { network ->
            val capabilities = manager.getNetworkCapabilities(network)
            capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true &&
                capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
        } ?: error("NETWORK_UNAVAILABLE")
    }
}
