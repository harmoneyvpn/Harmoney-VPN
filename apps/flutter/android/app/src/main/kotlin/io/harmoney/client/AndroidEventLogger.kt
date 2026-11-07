package io.harmoney.client

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.EventChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.concurrent.ConcurrentLinkedDeque
import java.util.concurrent.CopyOnWriteArrayList

object AndroidEventLogger : EventChannel.StreamHandler {
    const val TAG_VPN = "HarmoneyVpn"
    const val TAG_SERVICE = "HarmoneyVpnService"
    const val PHASE_PREPARING = "PREPARING"
    const val PHASE_DISCOVERING = "DISCOVERING"
    const val PHASE_CONNECTING = "CONNECTING"
    const val PHASE_AUTHENTICATING = "AUTHENTICATING"
    const val PHASE_VERIFYING = "VERIFYING"
    const val PHASE_CONNECTED = "CONNECTED"
    const val PHASE_CANCELLING = "CANCELLING"
    const val PHASE_DISCONNECTING = "DISCONNECTING"
    const val PHASE_FAILED = "FAILED"
    const val PHASE_RECOVERING = "RECOVERING"

    private const val MAX_LOGS = 500
    private val buffer = ConcurrentLinkedDeque<LogEntry>()
    private val eventSinks = CopyOnWriteArrayList<EventChannel.EventSink>()
    private val mainHandler = Handler(Looper.getMainLooper())
    private val timeFormat = SimpleDateFormat("HH:mm:ss.SSS", Locale.US)

    data class LogEntry(
        val timestamp: String,
        val level: String,
        val tag: String,
        val phase: String?,
        val message: String,
        val formatted: String,
        val protocol: String? = null,
        val provider: String? = null,
        val location: String? = null,
        val hostname: String? = null,
    ) {
        fun toMap(): Map<String, Any?> = mapOf(
            "timestamp" to timestamp,
            "level" to level,
            "tag" to tag,
            "phase" to phase,
            "message" to message,
            "formatted" to formatted,
            "protocol" to protocol,
            "provider" to provider,
            "location" to location,
            "hostname" to hostname,
        )
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events != null) {
            eventSinks.add(events)
            // Replay buffered logs to the new subscriber
            for (entry in buffer) {
                events.success(entry.formatted)
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSinks.clear()
    }

    fun log(
        level: String,
        tag: String,
        phase: String?,
        rawMessage: String,
        protocol: String? = null,
        provider: String? = null,
        location: String? = null,
        hostname: String? = null,
    ) {
        val timestamp = synchronized(timeFormat) { timeFormat.format(Date()) }
        val sanitized = redactSecrets(rawMessage)
        val formatted = buildString {
            append("[$level] ")
            append("[$timestamp] ")
            append("[$tag] ")
            if (!phase.isNullOrBlank()) {
                append("[$phase] ")
            }
            append(sanitized)
        }

        // Standard Android logcat tagging
        when (level.uppercase(Locale.US)) {
            "ERROR" -> Log.e(tag, formatted)
            "WARNING", "WARN" -> Log.w(tag, formatted)
            "DEBUG" -> Log.d(tag, formatted)
            else -> Log.i(tag, formatted)
        }

        val entry = LogEntry(
            timestamp = timestamp,
            level = level.uppercase(Locale.US),
            tag = tag,
            phase = phase,
            message = sanitized,
            formatted = formatted,
            protocol = protocol,
            provider = provider,
            location = location,
            hostname = hostname,
        )

        buffer.add(entry)
        while (buffer.size > MAX_LOGS) {
            buffer.pollFirst()
        }

        // Post formatted log to EventSinks
        mainHandler.post {
            for (sink in eventSinks) {
                runCatching { sink.success(formatted) }
            }
        }
    }

    fun info(tag: String, phase: String?, msg: String, protocol: String? = null, provider: String? = null, location: String? = null, hostname: String? = null) {
        log("INFO", tag, phase, msg, protocol, provider, location, hostname)
    }

    fun warn(tag: String, phase: String?, msg: String, protocol: String? = null, provider: String? = null, location: String? = null, hostname: String? = null) {
        log("WARNING", tag, phase, msg, protocol, provider, location, hostname)
    }

    fun error(tag: String, phase: String?, msg: String, protocol: String? = null, provider: String? = null, location: String? = null, hostname: String? = null) {
        log("ERROR", tag, phase, msg, protocol, provider, location, hostname)
    }

    fun getLogs(): List<String> = buffer.map { it.formatted }

    fun clear() {
        buffer.clear()
        info(TAG_VPN, null, "Log buffer cleared by user.")
    }

    fun exportSupportBundle(context: Context): String {
        val runtimeState = MobileVpnRuntimeState.snapshot(context)
        val networkFeatures = AndroidNetworkFeatures.diagnostics(context)
        return buildString {
            appendLine("=== HARMONEY VPN ANDROID SUPPORT BUNDLE ===")
            appendLine("Generated: ${SimpleDateFormat("yyyy-MM-dd HH:mm:ss Z", Locale.US).format(Date())}")
            appendLine("OS: Android ${android.os.Build.VERSION.RELEASE} (API ${android.os.Build.VERSION.SDK_INT})")
            appendLine("Device: ${android.os.Build.MANUFACTURER} ${android.os.Build.MODEL}")
            appendLine("Runtime State: $runtimeState")
            appendLine("Network Diag: $networkFeatures")
            appendLine("--- EVENT LOGS (${buffer.size} entries) ---")
            for (entry in buffer) {
                appendLine(entry.formatted)
            }
            appendLine("=== END OF SUPPORT BUNDLE ===")
        }
    }

    fun redactSecrets(input: String): String {
        var text = input
        text = text.replace(Regex(
            "(?:vless|vmess|ss|ssr|trojan|tuic|hysteria2?|hy2|wireguard)://[^\\s\\\"<>]+",
            RegexOption.IGNORE_CASE), "[REDACTED_PROXY_URI]")
        // Redact PEM private key blocks
        text = text.replace(
            Regex("-----BEGIN[ A-Z0-9_-]+KEY-----[^-]+-----END[ A-Z0-9_-]+KEY-----", setOf(RegexOption.IGNORE_CASE, RegexOption.MULTILINE)),
            "[REDACTED_KEY_BLOCK]"
        )
        // Redact key-value pairs of sensitive credentials
        text = text.replace(
            Regex("(password|passwd|service_pass|token|auth_token|secret|private_key|privatekey)=[^\\s,;]+", RegexOption.IGNORE_CASE),
            "$1=[REDACTED]"
        )
        // Redact JSON/quoted forms of password/token
        text = text.replace(
            Regex("(\"(?:password|service_pass|token|secret|private_key)\"\\s*:\\s*\")[^\"]+(\")", RegexOption.IGNORE_CASE),
            "$1[REDACTED]$2"
        )
        // Redact eap_id
        text = text.replace(
            Regex("(eap_id|eapid)=[^\\s,;]+", RegexOption.IGNORE_CASE),
            "$1=[REDACTED_EAP]"
        )
        text = text.replace(
            Regex("eap_id:\\s*\"[^\"]+\"", RegexOption.IGNORE_CASE),
            "eap_id: \"[REDACTED_EAP]\""
        )
        // Redact usernames partially to preserve debuggability while concealing PII (e.g. u***r)
        text = text.replace(
            Regex("(username|service_user)=([^\\s,;]+)", RegexOption.IGNORE_CASE)
        ) { match ->
            val key = match.groupValues[1]
            val value = match.groupValues[2]
            val masked = if (value.length <= 2) "***" else "${value.first()}***${value.last()}"
            "$key=$masked"
        }
        return text
    }

    fun redactUsername(name: String): String {
        if (name.isBlank()) return "redacted"
        return if (name.length <= 2) "***" else "${name.first()}***${name.last()}"
    }
}
