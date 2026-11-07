package io.harmoney.client

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Debug
import android.provider.Settings
import java.io.File
import java.net.Inet4Address
import java.net.InetAddress
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.harmoney.client.firefox.data.SettingsStore

class AndroidProtectionBridge(private val context: Context) {
    private val prefs = context.getSharedPreferences("android_protection", Context.MODE_PRIVATE)

    fun handle(call: MethodCall, result: MethodChannel.Result): Boolean {
        when (call.method) {
            "protectionState" -> result.success(state())
            "runtimeSecurityStatus" -> result.success(runtimeSecurityStatus())
            "setDnsProtection" -> {
                val enabled = call.argument<Boolean>("enabled") == true
                prefs.edit().putBoolean("dns_protection", enabled).apply()
                SettingsStore(context).customDnsEnabled = enabled
                result.success(state())
            }
            "setIpv6Protection" -> {
                prefs.edit().putBoolean("ipv6_protection", call.argument<Boolean>("enabled") == true).apply()
                result.success(state())
            }
            "getSplitCidrBypass" -> result.success(splitCidrState())
            "setSplitCidrBypass" -> {
                try {
                    val enabled = call.argument<Boolean>("enabled") == true
                    val cidrs = call.argument<List<String>>("cidrs") ?: emptyList()
                    val normalized = cidrs.map(::normalizeCidr).toSet()
                    prefs.edit()
                        .putBoolean("split_cidr_enabled", enabled)
                        .putStringSet("split_bypass_cidrs", normalized)
                        .apply()
                    result.success(splitCidrState())
                } catch (e: Exception) {
                    result.error("SPLIT_CIDR_INVALID", e.message, null)
                }
            }
            "openVpnSettings" -> {
                context.startActivity(Intent(Settings.ACTION_VPN_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                result.success(null)
            }
            "openTetherSettings" -> {
                try {
                    val intent = Intent("android.settings.TETHER_SETTINGS").addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    try {
                        val fallback = Intent(Settings.ACTION_WIRELESS_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        context.startActivity(fallback)
                        result.success(true)
                    } catch (e2: Exception) {
                        result.error("TETHER_SETTINGS_FAILED", e2.message, null)
                    }
                }
            }
            "listInstalledApps" -> {
                try {
                    val pm = context.packageManager
                    val intent = Intent(Intent.ACTION_MAIN, null).apply {
                        addCategory(Intent.CATEGORY_LAUNCHER)
                    }
                    val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        pm.queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(0))
                    } else {
                        @Suppress("DEPRECATION")
                        pm.queryIntentActivities(intent, 0)
                    }
                    val packages = resolveInfos
                        .map { it.activityInfo.packageName }
                        .filter { it != context.packageName }
                        .distinct()
                        .sorted()
                    result.success(packages)
                } catch (e: Exception) {
                    result.error("APP_LIST_FAILED", e.message, null)
                }
            }
            "setAppSplitTunneling" -> {
                try {
                    val disallowed = call.argument<List<String>>("disallowedPackages") ?: emptyList()
                    val allowed = call.argument<List<String>>("allowedPackages") ?: emptyList()
                    SettingsStore(context).excludedApps = disallowed.toSet()
                    prefs.edit()
                        .putStringSet("disallowed_packages", disallowed.toSet())
                        .putBoolean("split_tunneling", disallowed.isNotEmpty())
                        .apply()
                    result.success(null)
                } catch (e: Exception) {
                    result.error("SPLIT_FAILED", e.message, null)
                }
            }
            else -> return false
        }
        return true
    }

    private fun runtimeSecurityStatus(): Map<String, Any> {
        val rootPaths = listOf(
            "/system/bin/su",
            "/system/xbin/su",
            "/sbin/su",
            "/su/bin/su",
            "/system/bin/.ext/.su",
            "/system/app/Superuser.apk",
            "/data/adb/magisk",
            "/data/adb/ksu",
            "/data/adb/ap",
            "/debug_ramdisk/.magisk",
            "/system/framework/XposedBridge.jar",
            "/data/local/tmp/frida-server",
            "/data/local/tmp/re.frida.server",
            "/data/local/tmp/frida",
        )
        val testKeys = Build.TAGS?.contains("test-keys", ignoreCase = true) == true
        val suBinary = rootPaths.any { File(it).exists() }
        val tracerPid = runCatching {
            File("/proc/self/status").useLines { lines ->
                lines.firstOrNull { it.startsWith("TracerPid:") }
                    ?.substringAfter(':')?.trim()?.toIntOrNull()
            }
        }.getOrNull()
        val mapsInspection = runCatching {
            File("/proc/self/maps").useLines { lines ->
                val suspicious = lines.any { line ->
                    val lower = line.lowercase()
                    listOf("frida", "gum-js-loop", "xposed", "lsposed", "substrate", "zygisk", "riru")
                        .any(lower::contains)
                }
                suspicious
            }
        }
        val suspiciousMaps = mapsInspection.getOrDefault(false)
        val postureCheckFailed = tracerPid == null || !mapsInspection.isSuccess
        val debuggable = (context.applicationInfo.flags and
            android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0
        val debuggerAttached = Debug.isDebuggerConnected() || Debug.waitingForDebugger()
        val tracerAttached = (tracerPid ?: 0) > 0

        val filesPath = context.filesDir.absolutePath
        val virtualEnvironment = filesPath.contains("com.lbe.parallel") ||
            filesPath.contains("io.va.exposed") ||
            filesPath.contains("com.vphonegaga") ||
            filesPath.contains("com.dual.parallel") ||
            filesPath.contains("virtual") ||
            filesPath.contains("clone")

        val signatureCompromised = runCatching {
            val pm = context.packageManager
            val sigs = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                pm.getPackageInfo(context.packageName, PackageManager.GET_SIGNING_CERTIFICATES).signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                pm.getPackageInfo(context.packageName, PackageManager.GET_SIGNATURES).signatures
            }
            val certBytes = sigs?.firstOrNull()?.toByteArray() ?: return@runCatching false
            val md = java.security.MessageDigest.getInstance("SHA-256")
            val hash = md.digest(certBytes).joinToString("") { "%02x".format(it) }
            val isKnownDebugKey = hash.equals("32a2fc74d731105859e5a85df16d95f102815f222440424a2d8e06399a9a08e6", ignoreCase = true)
            !debuggable && isKnownDebugKey
        }.getOrDefault(false)

        val fridaPortOpen = runCatching {
            java.net.Socket().use { s ->
                s.connect(java.net.InetSocketAddress("127.0.0.1", 27042), 150)
                true
            }
        }.getOrDefault(false)

        val rootIndicators = testKeys || suBinary || tracerAttached || suspiciousMaps || postureCheckFailed || fridaPortOpen
        val overallPostureFailed = postureCheckFailed || suspiciousMaps || virtualEnvironment || signatureCompromised || fridaPortOpen

        return mapOf(
            "debugger_attached" to debuggerAttached,
            "debuggable_build" to debuggable,
            "root_indicators" to rootIndicators,
            "tracer_attached" to tracerAttached,
            "instrumentation_indicators" to (suspiciousMaps || fridaPortOpen),
            "posture_check_failed" to overallPostureFailed,
            "virtual_environment" to virtualEnvironment,
            "signature_compromised" to signatureCompromised,
        )
    }

    private fun state(): Map<String, Any?> {
        val alwaysOnPackage = runCatching {
            Settings.Secure.getString(context.contentResolver, "always_on_vpn_app")
        }.getOrNull()
        val lockdown = runCatching {
            Settings.Secure.getInt(context.contentResolver, "always_on_vpn_lockdown", 0) == 1
        }.getOrDefault(false)
        val excluded = SettingsStore(context).excludedApps
        val cidrBypassEnabled = prefs.getBoolean("split_cidr_enabled", false)
        return mapOf(
            "dns_protection" to prefs.getBoolean("dns_protection", true),
            "ipv6_protection" to prefs.getBoolean("ipv6_protection", true),
            "always_on" to (alwaysOnPackage == context.packageName),
            "lockdown" to (alwaysOnPackage == context.packageName && lockdown),
            "vpn_package" to alwaysOnPackage,
            "firefox_dns" to SettingsStore(context).effectiveCustomDnsServer,
            "requires_reconnect" to true,
            "split_tunneling" to excluded.isNotEmpty(),
            "split_enabled" to (excluded.isNotEmpty() || cidrBypassEnabled),
            "disallowed_packages" to excluded.toList(),
            "split_cidr_enabled" to prefs.getBoolean("split_cidr_enabled", false),
            "split_cidrs" to prefs.getStringSet("split_bypass_cidrs", emptySet())?.toList().orEmpty(),
        )
    }

    private fun splitCidrState(): Map<String, Any?> = mapOf(
        "enabled" to prefs.getBoolean("split_cidr_enabled", false),
        "cidrs" to prefs.getStringSet("split_bypass_cidrs", emptySet())?.toList().orEmpty().sorted(),
        "requires_reconnect" to true,
    )

    private fun normalizeCidr(value: String): String {
        val parts = value.trim().split('/')
        require(parts.size == 2) { "Enter a network in CIDR notation, such as 192.168.1.0/24." }
        val rawAddress = parts[0]
        require(!rawAddress.contains('%')) { "Scoped IPv6 addresses are not supported." }
        require(rawAddress.contains(':') || rawAddress.matches(Regex("[0-9.]+"))) {
            "Only IPv4 and IPv6 addresses are accepted."
        }
        val address = InetAddress.getByName(rawAddress)
        val prefix = parts[1].toIntOrNull()
            ?: throw IllegalArgumentException("CIDR prefix must be a number.")
        val maxPrefix = if (address is Inet4Address) 32 else 128
        require(prefix in 1..maxPrefix) { "CIDR prefix must be between 1 and $maxPrefix." }
        return "${address.hostAddress}/$prefix"
    }
}
