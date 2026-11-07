package io.harmoney.client

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import java.util.concurrent.atomic.AtomicReference

internal object MobileVpnRuntimeState {
    private const val PREFS = "vpn_runtime_state"
    private const val KEY_STATE = "state"
    private const val KEY_PROTOCOL = "protocol"
    private const val KEY_TRANSPORT = "transport"
    private const val KEY_PROVIDER = "provider"
    private const val KEY_SERVER_ID = "server_id"
    private const val KEY_HOSTNAME = "hostname"
    private const val KEY_MESSAGE = "message"
    private const val KEY_RETRY_COUNT = "retry_count"
    private const val KEY_CONNECTED_AT = "connected_at"

    private val state = AtomicReference("disconnected")
    private val protocol = AtomicReference<String?>(null)
    private val transport = AtomicReference<String?>(null)
    private val provider = AtomicReference<String?>(null)
    private val serverId = AtomicReference<String?>(null)
    private val hostname = AtomicReference<String?>(null)
    private val message = AtomicReference<String?>(null)
    private val retryCount = AtomicReference(0)
    private val connectedAtEpochMs = AtomicReference(0L)

    fun init(context: Context) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        state.set(prefs.getString(KEY_STATE, "disconnected") ?: "disconnected")
        protocol.set(prefs.getString(KEY_PROTOCOL, null))
        transport.set(prefs.getString(KEY_TRANSPORT, null))
        provider.set(prefs.getString(KEY_PROVIDER, null))
        serverId.set(prefs.getString(KEY_SERVER_ID, null))
        hostname.set(prefs.getString(KEY_HOSTNAME, null))
        message.set(prefs.getString(KEY_MESSAGE, null))
        retryCount.set(prefs.getInt(KEY_RETRY_COUNT, 0))
        connectedAtEpochMs.set(prefs.getLong(KEY_CONNECTED_AT, 0L))
    }

    fun update(
        newState: String,
        activeProtocol: String? = protocol.get(),
        detail: String? = null,
        activeProvider: String? = provider.get(),
        activeServerId: String? = serverId.get(),
        activeHostname: String? = hostname.get(),
        retries: Int? = null,
        context: Context? = null,
    ) {
        val oldState = state.get()
        if (newState == "connected" && oldState != "connected") {
            connectedAtEpochMs.set(System.currentTimeMillis())
        } else if (newState in setOf("disconnected", "failed")) {
            connectedAtEpochMs.set(0L)
        }
        if (newState in setOf("connecting", "disconnected", "failed", "disconnecting", "recovering")) {
            transport.set(null)
        }
        state.set(newState)
        protocol.set(activeProtocol)
        message.set(detail)
        if (activeProvider != null) provider.set(activeProvider)
        if (activeServerId != null) serverId.set(activeServerId)
        if (activeHostname != null) hostname.set(activeHostname)
        if (retries != null) retryCount.set(retries)

        context?.getSharedPreferences(PREFS, Context.MODE_PRIVATE)?.edit()?.apply {
            putString(KEY_STATE, newState)
            putString(KEY_PROTOCOL, activeProtocol)
            putString(KEY_TRANSPORT, transport.get())
            putString(KEY_PROVIDER, provider.get())
            putString(KEY_SERVER_ID, serverId.get())
            putString(KEY_HOSTNAME, hostname.get())
            putString(KEY_MESSAGE, detail)
            putInt(KEY_RETRY_COUNT, retryCount.get())
            putLong(KEY_CONNECTED_AT, connectedAtEpochMs.get())
            apply()
        }
        context?.let {
            VpnTileService.updateTile(it)
            HarmoneyWidgetProvider.refresh(it)
        }
    }

    fun clear(context: Context? = null) {
        state.set("disconnected")
        protocol.set(null)
        transport.set(null)
        provider.set(null)
        serverId.set(null)
        hostname.set(null)
        message.set(null)
        retryCount.set(0)
        connectedAtEpochMs.set(0L)

        context?.getSharedPreferences(PREFS, Context.MODE_PRIVATE)?.edit()?.clear()?.apply()
        context?.let {
            VpnTileService.updateTile(it)
            HarmoneyWidgetProvider.refresh(it)
        }
    }

    fun setTransport(value: String?, context: Context) {
        transport.set(value)
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putString(KEY_TRANSPORT, value).apply()
    }

    fun currentState(): String = state.get()
    fun activeProtocol(): String? = protocol.get()
    fun activeProvider(): String? = provider.get()
    fun activeServerId(): String? = serverId.get()
    fun activeHostname(): String? = hostname.get()
    fun activeMessage(): String? = message.get()
    fun currentRetryCount(): Int = retryCount.get()
    fun connectedAtEpochMs(): Long = connectedAtEpochMs.get()

    internal fun normalizeState(current: String, systemVpnUp: Boolean): String = when {
        // An interface does not prove authentication or traffic verification.
        !systemVpnUp && current in setOf("disconnecting", "cancelling", "connected") -> "disconnected"
        else -> current
    }

    fun snapshot(context: Context): Map<String, Any?> {
        val cm = context.getSystemService(ConnectivityManager::class.java)
        val systemVpnUp = cm?.allNetworks?.any { network ->
            cm.getNetworkCapabilities(network)
                ?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true
        } == true

        val current = state.get()
        val savedProtocol = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY_PROTOCOL, null)
        val activeProto = protocol.get() ?: savedProtocol

        val normalized = normalizeState(current, systemVpnUp)

        if (normalized == "disconnected" && current != "disconnected") {
            clear(context)
        }

        return mapOf(
            "state" to normalized,
            "transport" to if (normalized == "connected") transport.get() else null,
            "protocol" to if (normalized == "disconnected") null else activeProto,
            "provider" to provider.get(),
            "serverId" to serverId.get(),
            "hostname" to hostname.get(),
            "message" to message.get(),
            "retryCount" to retryCount.get(),
            "systemVpnActive" to systemVpnUp,
        )
    }
}
