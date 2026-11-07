package io.harmoney.client

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.SystemClock
import android.widget.RemoteViews
import androidx.core.content.ContextCompat

class HarmoneyWidgetProvider : AppWidgetProvider() {
    companion object {
        internal const val ACTION_TOGGLE = "io.harmoney.client.widget.TOGGLE"

        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, HarmoneyWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            if (ids.isNotEmpty()) HarmoneyWidgetProvider().onUpdate(context, manager, ids)
        }

        private fun isConnected(context: Context): Boolean =
            HarmoneyVpnService.gatewayVerified() ||
                MobileVpnRuntimeState.snapshot(context)["state"] == "connected"

        private fun isConnecting(): Boolean =
            HarmoneyVpnService.status in setOf("connecting", "verifying", "recovering", "reconnecting") ||
                MobileVpnRuntimeState.currentState() in setOf("connecting", "verifying", "recovering", "reconnecting")

        internal fun toggle(context: Context) {
            if (isConnected(context) || isConnecting()) {
                context.startService(
                    Intent(context, HarmoneyVpnService::class.java).setAction(HarmoneyVpnService.STOP))
            } else {
                HarmoneyWidgetProvider().connect(context)
            }
            refresh(context)
        }
    }

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        ids.forEach { id ->
            val connected = isConnected(context)
            val connecting = isConnecting()
            val views = RemoteViews(context.packageName, R.layout.harmoney_widget)
            val status = if (connected) "Connected" else if (connecting) "Connecting" else "Disconnected"
            val persianStatus = if (connected) "\u0645\u062a\u0635\u0644"
                else if (connecting) "\u062f\u0631 \u062d\u0627\u0644 \u0627\u062a\u0635\u0627\u0644"
                else "\u0642\u0637\u0639 \u0634\u062f"
            views.setTextViewText(R.id.widget_status,
                label(context, status, persianStatus))
            views.setTextViewText(R.id.widget_server, currentServer(context))
            val traffic = AndroidNetworkFeatures.trafficSnapshot(context)
            val todayBytes = (traffic["day_rx_bytes"] as? Number)?.toLong().orZero() +
                (traffic["day_tx_bytes"] as? Number)?.toLong().orZero()
            views.setTextViewText(R.id.widget_usage,
                "${label(context, "Today", "\u0627\u0645\u0631\u0648\u0632")}: ${formatBytes(todayBytes)}")
            views.setTextViewText(R.id.widget_toggle,
                label(context, if (connected) "Disconnect" else if (connecting) "Cancel" else "Connect",
                    if (connected) "\u0642\u0637\u0639 \u0627\u062a\u0635\u0627\u0644" else if (connecting) "\u0644\u063a\u0648" else "\u0627\u062a\u0635\u0627\u0644"))
            if (connected) {
                val startedAt = (if (HarmoneyVpnService.status == "connected")
                    HarmoneyVpnService.connectedAtEpochMs else MobileVpnRuntimeState.connectedAtEpochMs())
                    .takeIf { it > 0L } ?: System.currentTimeMillis()
                val elapsedBase = SystemClock.elapsedRealtime() -
                    (System.currentTimeMillis() - startedAt).coerceAtLeast(0L)
                views.setChronometer(R.id.widget_duration, elapsedBase, null, true)
                views.setViewVisibility(R.id.widget_duration, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_duration, android.view.View.GONE)
            }
            val toggle = Intent(context, HarmoneyWidgetActionReceiver::class.java).setAction(ACTION_TOGGLE)
            views.setOnClickPendingIntent(R.id.widget_toggle, PendingIntent.getBroadcast(
                context, 0, toggle, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))
            val open = Intent(context, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            views.setOnClickPendingIntent(R.id.widget_root, PendingIntent.getActivity(
                context, 1, open, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))
            manager.updateAppWidget(id, views)
        }
    }

    private fun connect(context: Context) {
        if (VpnService.prepare(context) != null) {
            context.startActivity(Intent(context, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                .putExtra("widget_connect", true))
            return
        }
        ContextCompat.startForegroundService(context,
            Intent(context, HarmoneyVpnService::class.java)
                .setAction(HarmoneyVpnService.START)
                .putExtra("pattern", "auto")
                .putExtra("flowLine", ""))
    }

    private fun currentServer(context: Context): String {
        val host = MobileVpnRuntimeState.activeHostname()
        if (isConnected(context) && !host.isNullOrBlank()) return host.take(32)
        if (HarmoneyVpnService.status == "connected") return "Harmoney Smart"
        val id = context.getSharedPreferences("vpn_runtime", Context.MODE_PRIVATE)
            .getString("server_id", null)?.take(24)
        return id ?: label(context, "Tap to open server list", "\u0628\u0631\u0627\u06cc \u062f\u06cc\u062f\u0646 \u0641\u0647\u0631\u0633\u062a \u0644\u0645\u0633 \u06a9\u0646\u06cc\u062f")
    }

    private fun label(context: Context, english: String, persian: String): String {
        val locale = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .getString("flutter.locale", "fa")?.substringBefore('-')
        return if (locale == "fa") persian else english
    }

    private fun formatBytes(bytes: Long): String = when {
        bytes >= 1024L * 1024 * 1024 -> "%.1f GB".format(bytes / (1024.0 * 1024 * 1024))
        bytes >= 1024L * 1024 -> "%.1f MB".format(bytes / (1024.0 * 1024))
        bytes >= 1024L -> "%.0f KB".format(bytes / 1024.0)
        else -> "$bytes B"
    }
}

private fun Long?.orZero(): Long = this ?: 0L
