package io.harmoney.client

import android.content.Intent
import android.net.VpnService

/**
 * Compatibility service declaration for public builds. Harmoney Smart owns
 * its VPN data path in HarmoneyVpnService; unsupported manual profiles fail
 * explicitly instead of claiming a connected state.
 */
class HarmoneyIkev2VpnService : VpnService() {
    companion object {
        const val ACTION_CONNECT = "io.harmoney.client.CONNECT"
        const val ACTION_DISCONNECT = "io.harmoney.client.DISCONNECT"
        const val EXTRA_SERVER_ID = "server_id"
        const val EXTRA_PROVIDER_ID = "provider_id"
        const val EXTRA_PROTOCOL = "protocol"
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        if (action == ACTION_DISCONNECT) {
            MobileVpnRuntimeState.clear(this)
        } else if (action == ACTION_CONNECT) {
            val protocol = intent.getStringExtra(EXTRA_PROTOCOL) ?: "unknown"
            MobileVpnRuntimeState.update(
                "failed",
                protocol,
                "This manual VPN protocol is not included in the public edition.",
                context = this,
            )
        }
        stopSelfResult(startId)
        return START_NOT_STICKY
    }
}
