package io.harmoney.client

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private var physicalNetworkEvents: PhysicalNetworkEvents? = null
    private val channelName = "io.harmoney.client/android"
    private val eventChannelName = "io.harmoney.client/android_events"
    private val prepareRequestCode = 4102
    private var pendingPrepareResult: MethodChannel.Result? = null
    private lateinit var firefoxBridge: FirefoxVpnBridge
    private lateinit var protectionBridge: AndroidProtectionBridge
    private lateinit var methodChannel: MethodChannel
    private var harmoneyStatusSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        physicalNetworkEvents = PhysicalNetworkEvents(applicationContext).also {
            EventChannel(flutterEngine.dartExecutor.binaryMessenger, "io.harmoney.client/physical_network")
                .setStreamHandler(it)
        }
        firefoxBridge = FirefoxVpnBridge(applicationContext, this)
        protectionBridge = AndroidProtectionBridge(applicationContext)

        // Event Channel for real-time live connection event logs
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannelName)
            .setStreamHandler(AndroidEventLogger)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.harmoney.vpn_events")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    harmoneyStatusSink = events
                    events.success(mapOf("status" to HarmoneyVpnService.status))
                }
                override fun onCancel(arguments: Any?) { harmoneyStatusSink = null }
            })
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.harmoney.progress_events")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {}
                override fun onCancel(arguments: Any?) {}
            })
        HarmoneyVpnService.onStatus = { event ->
            runOnUiThread { harmoneyStatusSink?.success(event) }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.harmoney.vpn")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                "installApk" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath.isNullOrBlank()) {
                        result.error("INVALID_PATH", "File path cannot be empty", null)
                        return@setMethodCallHandler
                    }
                    val file = java.io.File(filePath)
                    if (!file.exists()) {
                        result.error("FILE_NOT_FOUND", "File does not exist: $filePath", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val apkUri = androidx.core.content.FileProvider.getUriForFile(
                            this,
                            "${applicationContext.packageName}.fileprovider",
                            file
                        )
                        val intent = android.content.Intent(android.content.Intent.ACTION_VIEW).apply {
                            setDataAndType(apkUri, "application/vnd.android.package-archive")
                            addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                            addFlags(android.content.Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INSTALL_ERROR", e.message, null)
                    }
                }

                    "capabilities" -> thread {
                        val engine = runCatching { HarmoneyEngine.load(applicationContext) }
                        runOnUiThread { result.success(mapOf(
                            "system_tunnel" to engine.isSuccess,
                            "traffic_verification" to engine.isSuccess,
                            "verification_scope" to "native_tun_start_and_gateway_https_dns",
                            "reason" to engine.exceptionOrNull()?.message
                        )) }
                    }
                    "connect", "startVPN" -> {
                        if (VpnService.prepare(this) != null) {
                            result.error("VPN_PERMISSION_DENIED", "VPN permission is required", null)
                        } else {
                            if (Build.VERSION.SDK_INT >= 33 &&
                                ContextCompat.checkSelfPermission(this, android.Manifest.permission.POST_NOTIFICATIONS)
                                != PackageManager.PERMISSION_GRANTED) {
                                requestPermissions(arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 4104)
                            }
                            ContextCompat.startForegroundService(this,
                                Intent(this, HarmoneyVpnService::class.java).setAction(HarmoneyVpnService.START)
                                    .putExtra("pattern", call.argument<String>("pattern")?.ifBlank { "auto" } ?: "auto")
                                    .putExtra("flowLine", call.argument<String>("flowLine") ?: ""))
                            result.success(true)
                        }
                    }
                    "disconnect", "stopVPN" -> {
                        if (HarmoneyVpnService.status != "disconnected") {
                            startService(Intent(this, HarmoneyVpnService::class.java).setAction(HarmoneyVpnService.STOP))
                        }
                        result.success(true)
                    }
                    "getVpnStatus" -> result.success(HarmoneyVpnService.status)
                    "getLastError" -> result.success(HarmoneyVpnService.lastError)
                    "isTunnelRunning" -> result.success(HarmoneyVpnService.tunnelRunning)
                    "verifyGateway" -> result.success(HarmoneyVpnService.gatewayVerified())
                    "prepareVPN", "grantVpnPermission" -> prepareFirefoxVpn(result)
                    "calculatePing" -> result.success(0)
                    "getFlag" -> result.success(HarmoneyVpnService.egressCountry)
                    "getSharedDirectory" -> result.success(filesDir.absolutePath)
                    "setCacheDir", "setTimezone" -> result.success(null)
                    else -> result.notImplemented()
                }
            }

        val vibrationChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.harmoney.vibration")
        vibrationChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "installApk" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath.isNullOrBlank()) {
                        result.error("INVALID_PATH", "File path cannot be empty", null)
                        return@setMethodCallHandler
                    }
                    val file = java.io.File(filePath)
                    if (!file.exists()) {
                        result.error("FILE_NOT_FOUND", "File does not exist: $filePath", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val apkUri = androidx.core.content.FileProvider.getUriForFile(
                            this,
                            "${applicationContext.packageName}.fileprovider",
                            file
                        )
                        val intent = android.content.Intent(android.content.Intent.ACTION_VIEW).apply {
                            setDataAndType(apkUri, "application/vnd.android.package-archive")
                            addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                            addFlags(android.content.Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INSTALL_ERROR", e.message, null)
                    }
                }

                "hasVibrator" -> result.success(true)
                "vibrate" -> result.success(true)
                "cancel" -> result.success(null)
                else -> result.notImplemented()
            }
        }

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "installApk" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath.isNullOrBlank()) {
                        result.error("INVALID_PATH", "File path cannot be empty", null)
                        return@setMethodCallHandler
                    }
                    val file = java.io.File(filePath)
                    if (!file.exists()) {
                        result.error("FILE_NOT_FOUND", "File does not exist: $filePath", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val apkUri = androidx.core.content.FileProvider.getUriForFile(
                            this,
                            "${applicationContext.packageName}.fileprovider",
                            file
                        )
                        val intent = android.content.Intent(android.content.Intent.ACTION_VIEW).apply {
                            setDataAndType(apkUri, "application/vnd.android.package-archive")
                            addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                            addFlags(android.content.Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INSTALL_ERROR", e.message, null)
                    }
                }

                "prepare" -> {
                    val requestedProtocol = call.argument<String>("protocol")
                    if (requestedProtocol == "firefox") {
                        prepareFirefoxVpn(result)
                    } else {
                        result.error(
                            "unsupported_protocol",
                            "This edition only supports the Firefox VPN permission flow.",
                            null,
                        )
                    }
                }
                "testInternet" -> thread { runOnUiThread { result.success(AndroidNetworkFeatures.testInternet()) } }
                "testDns" -> thread { runOnUiThread { result.success(AndroidNetworkFeatures.testDns()) } }
                "diagnostics" -> result.success(AndroidNetworkFeatures.diagnostics(this))
                "trafficSnapshot" -> result.success(AndroidNetworkFeatures.trafficSnapshot(this))
                "testServer" -> thread {
                    val host = call.argument<String>("hostname") ?: "127.0.0.1"
                    val outcome = AndroidNetworkFeatures.testServer(host)
                    runOnUiThread { result.success(outcome) }
                }
                "getLogs" -> result.success(AndroidEventLogger.getLogs())
                "clearLogs" -> { AndroidEventLogger.clear(); result.success(true) }
                "exportSupportBundle" -> result.success(AndroidEventLogger.exportSupportBundle(this))
                "getCountryBypassState" -> result.success(CountryBypassRuleManager.getInstance(this).getState())
                "setCountryBypassEnabled" -> result.success(CountryBypassRuleManager.getInstance(this).setEnabled(call.argument<Boolean>("enabled") == true))
                "getSelectedBypassCountries" -> result.success(CountryBypassRuleManager.getInstance(this).getSelectedCountries())
                "setSelectedBypassCountries" -> result.success(CountryBypassRuleManager.getInstance(this).setSelectedCountries(call.argument<List<String>>("countries") ?: emptyList()))
                "updateCountryBypassRules" -> thread {
                    val outcome = CountryBypassRuleManager.getInstance(this).updateRules()
                    runOnUiThread { result.success(outcome) }
                }
                "getCountryBypassDiagnostics" -> result.success(CountryBypassRuleManager.getInstance(this).getDiagnostics())
                else -> if (!firefoxBridge.handle(call, result) &&
                    !protectionBridge.handle(call, result)
                ) result.notImplemented()
            }
        }
    }

    private fun prepareFirefoxVpn(result: MethodChannel.Result) {
        val intent = VpnService.prepare(this)
        if (intent == null) {
            result.success(true)
            return
        }
        if (pendingPrepareResult != null) {
            result.error("PREPARE_IN_PROGRESS", "VPN permission request dialog is already open", null)
            return
        }
        pendingPrepareResult = result
        startActivityForResult(intent, prepareRequestCode)
    }

    @Deprecated("Deprecated in Android")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            FirefoxVpnBridge.BROWSER_LOGIN_REQUEST_CODE -> {
                firefoxBridge.onBrowserLoginResult(resultCode)
            }
            prepareRequestCode -> {
                val granted = resultCode == Activity.RESULT_OK
                pendingPrepareResult?.success(granted)
                pendingPrepareResult = null
            }
        }
    }

    override fun onDestroy() {
        physicalNetworkEvents?.close()
        HarmoneyVpnService.onStatus = null
        harmoneyStatusSink = null
        super.onDestroy()
    }
}
