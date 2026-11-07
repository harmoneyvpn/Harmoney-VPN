package io.harmoney.client

import android.content.Context
import android.content.SharedPreferences
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.ByteArrayOutputStream
import java.net.HttpURLConnection
import java.net.InetAddress
import java.net.URL
import java.math.BigInteger
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap
import kotlin.concurrent.thread

data class CountryRuleEntry(
    val code: String,
    val name: String,
    val flag: String,
    val ipv4: List<String>,
    val ipv6: List<String>,
) {
    val totalCount: Int get() = ipv4.size + ipv6.size
}

class CountryBypassRuleManager private constructor(private val context: Context) {
    companion object {
        private const val PREFS_NAME = "country_bypass_prefs"
        private const val KEY_ENABLED = "country_bypass_enabled"
        private const val KEY_SELECTED_COUNTRIES = "country_bypass_selected_countries"
        private const val KEY_UPDATED_AT = "country_bypass_updated_at"
        private const val KEY_LAST_DAT_CHECK = "country_bypass_last_dat_check"
        private const val CACHE_FILE_NAME = "country_bypass_cache.json"
        private const val ASSET_FILE_NAME = "country_cidr_dataset.json"
        private const val GEOIP_ASSET = "geoip-ir.dat"
        private const val GEOIP_CACHE = "country_geoip_ir.dat"
        private const val GEOSITE_CACHE = "country_geosite_ir.dat"
        private const val GEOIP_URL = "https://raw.githubusercontent.com/Chocolate4U/Iran-v2ray-rules/release/geoip-lite.dat"
        private const val GEOSITE_URL = "https://raw.githubusercontent.com/Chocolate4U/Iran-v2ray-rules/release/geosite-lite.dat"

        @Volatile
        private var instance: CountryBypassRuleManager? = null

        fun getInstance(context: Context): CountryBypassRuleManager {
            return instance ?: synchronized(this) {
                instance ?: CountryBypassRuleManager(context.applicationContext).also { instance = it }
            }
        }
    }

    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private val countriesMap = ConcurrentHashMap<String, CountryRuleEntry>()
    private val isoDateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US)
    private var lastError: String? = null
    @Volatile private var irDomains: Set<String> = emptySet()
    @Volatile private var ruleSource: String = "Bundled JSON"

    init {
        loadRules()
        refreshIfStale()
    }

    private fun refreshIfStale() {
        if (!isEnabled()) return
        val now = System.currentTimeMillis()
        if (now - prefs.getLong(KEY_LAST_DAT_CHECK, 0L) < 24 * 60 * 60 * 1000L) return
        prefs.edit().putLong(KEY_LAST_DAT_CHECK, now).apply()
        thread(name = "harmoney-country-dat-refresh", isDaemon = true) { updateRules() }
    }

    @Synchronized
    private fun loadRules() {
        try {
            val cacheFile = File(context.filesDir, CACHE_FILE_NAME)
            val jsonContent = if (cacheFile.exists() && cacheFile.length() > 0) {
                cacheFile.readText(Charsets.UTF_8)
            } else {
                val assetContent = context.assets.open(ASSET_FILE_NAME).bufferedReader(Charsets.UTF_8).use { it.readText() }
                // Persist to local cache for offline usage
                cacheFile.writeText(assetContent, Charsets.UTF_8)
                assetContent
            }
            parseAndPopulate(jsonContent)
            val geoipCache = File(context.filesDir, GEOIP_CACHE)
            val cachedRules = if (geoipCache.exists() && geoipCache.length() > 0) {
                runCatching { V2RayGeoData.readCountry(geoipCache.readBytes(), "IR") }.getOrNull()
            } else null
            val iranRules = cachedRules ?: V2RayGeoData.readCountry(
                context.assets.open(GEOIP_ASSET).use { it.readBytes() }, "IR"
            )
            ruleSource = if (cachedRules == null) "Bundled V2Ray GeoIP DAT" else "Updated V2Ray GeoIP DAT"
            applyIranRules(iranRules)
            val geositeCache = File(context.filesDir, GEOSITE_CACHE)
            if (geositeCache.exists()) {
                irDomains = runCatching { V2RayGeoData.readIranianDomains(geositeCache.readBytes()) }
                    .getOrDefault(emptySet())
            }
            lastError = null
        } catch (e: Exception) {
            lastError = "Failed to load country CIDR rules: ${e.message}"
            AndroidEventLogger.error(
                AndroidEventLogger.TAG_VPN,
                null,
                "CountryBypassRuleManager: error loading rules: ${e.message}",
            )
        }
    }

    private fun applyIranRules(rules: V2RayGeoData.IpRules) {
        require(rules.ipv4.size >= 100) { "Iran GeoIP rules are incomplete" }
        countriesMap["IR"] = CountryRuleEntry("IR", "Iran", "🇮🇷", rules.ipv4, rules.ipv6)
    }

    private fun downloadRules(url: String, maxBytes: Int): ByteArray {
        val connection = URL(url).openConnection() as HttpURLConnection
        connection.connectTimeout = 10_000
        connection.readTimeout = 20_000
        connection.instanceFollowRedirects = true
        try {
            require(connection.responseCode == HttpURLConnection.HTTP_OK) { "HTTP ${connection.responseCode}" }
            require(connection.contentLengthLong <= maxBytes) { "DAT is too large" }
            return connection.inputStream.use { stream ->
                val output = ByteArrayOutputStream()
                val chunk = ByteArray(16_384)
                while (true) {
                    val read = stream.read(chunk)
                    if (read < 0) break
                    require(output.size() + read <= maxBytes) { "DAT is too large" }
                    output.write(chunk, 0, read)
                }
                output.toByteArray().also { require(it.isNotEmpty()) { "Empty DAT download" } }
            }
        } finally {
            connection.disconnect()
        }
    }

    private fun saveAtomically(name: String, bytes: ByteArray) {
        val target = File(context.filesDir, name)
        val temporary = File(context.filesDir, "$name.tmp")
        temporary.writeBytes(bytes)
        check(temporary.renameTo(target)) { "Could not replace $name cache" }
    }

    private fun parseAndPopulate(jsonString: String) {
        val root = JSONObject(jsonString)
        val countriesArray = root.optJSONArray("countries") ?: JSONArray()
        countriesMap.clear()

        for (i in 0 until countriesArray.length()) {
            val obj = countriesArray.getJSONObject(i)
            val code = obj.getString("code").uppercase(Locale.US)
            val name = obj.getString("name")
            val flag = obj.optString("flag", "")
            val ipv4List = mutableListOf<String>()
            val ipv4Array = obj.optJSONArray("ipv4") ?: JSONArray()
            for (j in 0 until ipv4Array.length()) {
                val cidr = ipv4Array.getString(j).trim()
                if (cidr.isNotEmpty()) ipv4List.add(cidr)
            }

            val ipv6List = mutableListOf<String>()
            val ipv6Array = obj.optJSONArray("ipv6") ?: JSONArray()
            for (j in 0 until ipv6Array.length()) {
                val cidr = ipv6Array.getString(j).trim()
                if (cidr.isNotEmpty()) ipv6List.add(cidr)
            }

            countriesMap[code] = CountryRuleEntry(
                code = code,
                name = name,
                flag = flag,
                ipv4 = ipv4List,
                ipv6 = ipv6List,
            )
        }

        if (!prefs.contains(KEY_UPDATED_AT)) {
            val updatedAt = root.optString("updated_at", isoDateFormat.format(Date()))
            prefs.edit().putString(KEY_UPDATED_AT, updatedAt).apply()
        }
    }

    fun isEnabled(): Boolean = prefs.getBoolean(KEY_ENABLED, false)

    fun hasActiveBypassRoutes(): Boolean = isEnabled() ||
        context.getSharedPreferences("android_protection", Context.MODE_PRIVATE)
            .getBoolean("split_cidr_enabled", false) && getCustomBypassCidrs().isNotEmpty()

    private fun getCustomBypassCidrs(): List<String> {
        val protection = context.getSharedPreferences("android_protection", Context.MODE_PRIVATE)
        if (!protection.getBoolean("split_cidr_enabled", false)) return emptyList()
        return protection.getStringSet("split_bypass_cidrs", emptySet())
            ?.toList().orEmpty()
    }

    fun setEnabled(enabled: Boolean): Map<String, Any?> {
        prefs.edit().putBoolean(KEY_ENABLED, enabled).apply()
        if (enabled) refreshIfStale()
        AndroidEventLogger.info(
            AndroidEventLogger.TAG_VPN,
            null,
            "Country Bypass toggled: ${if (enabled) "ON" else "OFF"} (selected: ${getSelectedCountries().joinToString()})",
        )
        return getState()
    }

    fun getSelectedCountries(): List<String> {
        val set = prefs.getStringSet(KEY_SELECTED_COUNTRIES, null) ?: setOf("IR")
        return set.toList().sorted()
    }

    fun setSelectedCountries(countries: List<String>): Map<String, Any?> {
        val upperList = countries.map { it.uppercase(Locale.US) }.toSet()
        prefs.edit().putStringSet(KEY_SELECTED_COUNTRIES, upperList).apply()
        AndroidEventLogger.info(
            AndroidEventLogger.TAG_VPN,
            null,
            "Country Bypass selected countries updated: ${upperList.joinToString()}",
        )
        return getState()
    }

    @Synchronized
    fun updateRules(): Map<String, Any?> {
        prefs.edit().putLong(KEY_LAST_DAT_CHECK, System.currentTimeMillis()).apply()
        try {
            // Validate both downloaded protobufs before replacing the last known good cache.
            val geoip = downloadRules(GEOIP_URL, 8_000_000)
            val irRules = V2RayGeoData.readCountry(geoip, "IR")
            require(irRules.ipv4.size >= 100) { "Iran GeoIP rules are incomplete" }
            val geosite = downloadRules(GEOSITE_URL, 8_000_000)
            val domains = V2RayGeoData.readIranianDomains(geosite)
            saveAtomically(GEOIP_CACHE, geoip)
            saveAtomically(GEOSITE_CACHE, geosite)
            applyIranRules(irRules)
            irDomains = domains
            ruleSource = "Updated V2Ray GeoIP DAT"
            prefs.edit().putString(KEY_UPDATED_AT, isoDateFormat.format(Date())).apply()
            lastError = null

            AndroidEventLogger.info(
                AndroidEventLogger.TAG_VPN,
                null,
                "Country Bypass DAT refreshed: ${irRules.ipv4.size} Iranian IPv4 CIDRs, ${irRules.ipv6.size} IPv6 CIDRs, ${domains.size} domain rules. Reconnect VPN to apply.",
            )
        } catch (e: Exception) {
            lastError = "Update failed: ${e.message}"
            AndroidEventLogger.error(
                AndroidEventLogger.TAG_VPN,
                null,
                "Failed to update country rules: ${e.message}",
            )
        }
        return getState()
    }

    fun getState(): Map<String, Any?> {
        val available = countriesMap.values.sortedBy { it.name }.map {
            mapOf(
                "code" to it.code,
                "name" to it.name,
                "flag" to it.flag,
                "ipv4Count" to it.ipv4.size,
                "ipv6Count" to it.ipv6.size,
                "totalCount" to it.totalCount,
            )
        }

        val ruleCounts = countriesMap.mapValues { it.value.totalCount }

        return mapOf(
            "enabled" to isEnabled(),
            "selectedCountries" to getSelectedCountries(),
            "availableCountries" to available,
            "rulesUpdatedAt" to (prefs.getString(KEY_UPDATED_AT, null) ?: isoDateFormat.format(Date())),
            "countryRuleCounts" to ruleCounts,
            "ruleSource" to ruleSource,
            "iranianDomainRuleCount" to irDomains.size,
            "supported" to true,
            "error" to lastError,
        )
    }

    fun getDiagnostics(): Map<String, Any?> {
        val selected = getSelectedCountries()
        val activeV4 = getActiveBypassedIpv4Cidrs()
        val activeV6 = getActiveBypassedIpv6Cidrs()
        val cacheFile = File(context.filesDir, CACHE_FILE_NAME)

        return mapOf(
            "enabled" to isEnabled(),
            "selectedCountries" to selected,
            "activeBypassedIpv4Count" to activeV4.size,
            "activeBypassedIpv6Count" to activeV6.size,
            "sampleIpv4Cidrs" to activeV4.take(5),
            "sampleIpv6Cidrs" to activeV6.take(3),
            "cacheFilePresent" to cacheFile.exists(),
            "cacheSizeBytes" to if (cacheFile.exists()) cacheFile.length() else 0L,
            "rulesUpdatedAt" to prefs.getString(KEY_UPDATED_AT, "N/A"),
            "ruleSource" to ruleSource,
            "iranianDomainRuleCount" to irDomains.size,
            "routingDirectBypass" to if (isEnabled()) "Active" else "Disabled (Full Tunnel)",
        )
    }

    fun getActiveBypassedIpv4Cidrs(): List<String> {
        val result = mutableListOf<String>()
        if (isEnabled()) {
            for (code in getSelectedCountries()) {
                countriesMap[code.uppercase(Locale.US)]?.let {
                    result.addAll(it.ipv4)
                }
            }
        }
        result.addAll(getCustomBypassCidrs().filter { cidr ->
            cidr.substringBefore('/').contains('.')
        })
        return result.distinct()
    }

    fun getActiveBypassedIpv6Cidrs(): List<String> {
        val result = mutableListOf<String>()
        if (isEnabled()) {
            for (code in getSelectedCountries()) {
                countriesMap[code.uppercase(Locale.US)]?.let {
                    result.addAll(it.ipv6)
                }
            }
        }
        result.addAll(getCustomBypassCidrs().filter { cidr ->
            cidr.substringBefore('/').contains(':')
        })
        return result.distinct()
    }

    /**
     * Checks if a given destination IP address (IPv4 or IPv6) matches any currently active bypassed country CIDR.
     */
    fun isIpBypassed(ipStr: String): Boolean {
        if (!isEnabled()) return false
        val ip = runCatching { InetAddress.getByName(ipStr) }.getOrNull() ?: return false
        val bytes = ip.address

        if (bytes.size == 4) {
            // IPv4 matching
            val ipInt = ((bytes[0].toInt() and 0xFF) shl 24) or
                    ((bytes[1].toInt() and 0xFF) shl 16) or
                    ((bytes[2].toInt() and 0xFF) shl 8) or
                    (bytes[3].toInt() and 0xFF)

            val v4Cidrs = getActiveBypassedIpv4Cidrs()
            for (cidr in v4Cidrs) {
                if (matchesIpv4Cidr(ipInt, cidr)) return true
            }
        } else if (bytes.size == 16) {
            // IPv6 matching
            val v6Cidrs = getActiveBypassedIpv6Cidrs()
            for (cidr in v6Cidrs) {
                if (matchesIpv6Cidr(bytes, cidr)) return true
            }
        }
        return false
    }

    private fun matchesIpv4Cidr(ipInt: Int, cidr: String): Boolean {
        val parts = cidr.split('/')
        if (parts.size != 2) return false
        val baseIp = runCatching { InetAddress.getByName(parts[0]).address }.getOrNull() ?: return false
        if (baseIp.size != 4) return false
        val prefix = parts[1].toIntOrNull() ?: return false
        if (prefix !in 0..32) return false

        val baseInt = ((baseIp[0].toInt() and 0xFF) shl 24) or
                ((baseIp[1].toInt() and 0xFF) shl 16) or
                ((baseIp[2].toInt() and 0xFF) shl 8) or
                (baseIp[3].toInt() and 0xFF)

        if (prefix == 0) return true
        val mask = (-1 shl (32 - prefix))
        return (ipInt and mask) == (baseInt and mask)
    }

    private fun matchesIpv6Cidr(ipBytes: ByteArray, cidr: String): Boolean {
        val parts = cidr.split('/')
        if (parts.size != 2) return false
        val baseIp = runCatching { InetAddress.getByName(parts[0]).address }.getOrNull() ?: return false
        if (baseIp.size != 16) return false
        val prefix = parts[1].toIntOrNull() ?: return false
        if (prefix !in 0..128) return false

        var remaining = prefix
        for (i in 0 until 16) {
            if (remaining >= 8) {
                if (ipBytes[i] != baseIp[i]) return false
                remaining -= 8
            } else if (remaining > 0) {
                val mask = (0xFF shl (8 - remaining)) and 0xFF
                if ((ipBytes[i].toInt() and mask) != (baseIp[i].toInt() and mask)) return false
                break
            } else {
                break
            }
        }
        return true
    }

    /**
     * Calculates complement routes for IPv4 (0.0.0.0/0 minus excluded CIDRs)
     * using Trie recursive decomposition. Returns list of (address, prefixLength)
     * suitable for adding to VpnService.Builder or WireGuard AllowedIPs.
     */
    fun calculateComplementRoutesIpv4(excludedCidrs: List<String>): List<Pair<String, Int>> {
        if (excludedCidrs.isEmpty()) {
            return listOf("0.0.0.0" to 0)
        }

        class Node {
            var isExcluded = false
            var left: Node? = null
            var right: Node? = null
        }

        val root = Node()

        // Insert excluded CIDRs into binary trie
        for (cidr in excludedCidrs) {
            val parts = cidr.split('/')
            if (parts.size != 2) continue
            val baseIp = runCatching { InetAddress.getByName(parts[0]).address }.getOrNull() ?: continue
            if (baseIp.size != 4) continue
            val prefix = parts[1].toIntOrNull() ?: continue
            if (prefix !in 0..32) continue

            val ipInt = ((baseIp[0].toInt() and 0xFF) shl 24) or
                    ((baseIp[1].toInt() and 0xFF) shl 16) or
                    ((baseIp[2].toInt() and 0xFF) shl 8) or
                    (baseIp[3].toInt() and 0xFF)

            var curr = root
            for (bit in 31 downTo (32 - prefix)) {
                if (curr.isExcluded) break // Already excluded parent
                val isOne = ((ipInt shr bit) and 1) == 1
                if (isOne) {
                    if (curr.right == null) curr.right = Node()
                    curr = curr.right!!
                } else {
                    if (curr.left == null) curr.left = Node()
                    curr = curr.left!!
                }
            }
            curr.isExcluded = true
            curr.left = null
            curr.right = null
        }

        // Collect all non-excluded leaves
        val results = mutableListOf<Pair<String, Int>>()

        fun collect(node: Node?, currentIp: Int, depth: Int) {
            if (node == null) {
                // Whole sub-tree is included
                val ipStr = String.format(
                    Locale.US,
                    "%d.%d.%d.%d",
                    (currentIp ushr 24) and 0xFF,
                    (currentIp ushr 16) and 0xFF,
                    (currentIp ushr 8) and 0xFF,
                    currentIp and 0xFF
                )
                results.add(ipStr to depth)
                return
            }
            if (node.isExcluded) {
                // Pruned: This subnet is bypassed directly through ISP!
                return
            }
            if (node.left == null && node.right == null) {
                // Leaf that is not excluded
                val ipStr = String.format(
                    Locale.US,
                    "%d.%d.%d.%d",
                    (currentIp ushr 24) and 0xFF,
                    (currentIp ushr 16) and 0xFF,
                    (currentIp ushr 8) and 0xFF,
                    currentIp and 0xFF
                )
                results.add(ipStr to depth)
                return
            }

            collect(node.left, currentIp, depth + 1)
            val rightIp = currentIp or (1 shl (31 - depth))
            collect(node.right, rightIp, depth + 1)
        }

        collect(root, 0, 0)
        return results
    }

    /** IPv6 equivalent used by Android VpnService on API levels without excludeRoute(). */
    fun calculateComplementRoutesIpv6(excludedCidrs: List<String>): List<Pair<String, Int>> {
        if (excludedCidrs.isEmpty()) return listOf("::" to 0)

        class Node {
            var isExcluded = false
            var left: Node? = null
            var right: Node? = null
        }

        val root = Node()
        val one = BigInteger.ONE
        for (cidr in excludedCidrs) {
            val parts = cidr.split('/')
            if (parts.size != 2) continue
            val bytes = runCatching { InetAddress.getByName(parts[0]).address }.getOrNull() ?: continue
            if (bytes.size != 16) continue
            val prefix = parts[1].toIntOrNull() ?: continue
            if (prefix !in 0..128) continue
            val ip = BigInteger(1, bytes)
            var node = root
            for (bit in 127 downTo (128 - prefix)) {
                if (node.isExcluded) break
                node = if (ip.testBit(bit)) {
                    if (node.right == null) node.right = Node()
                    node.right!!
                } else {
                    if (node.left == null) node.left = Node()
                    node.left!!
                }
            }
            node.isExcluded = true
            node.left = null
            node.right = null
        }

        val results = mutableListOf<Pair<String, Int>>()
        fun collect(node: Node?, currentIp: BigInteger, depth: Int) {
            if (node == null) {
                val bytes = currentIp.toByteArray().let { raw ->
                    ByteArray(16) { index ->
                        val sourceIndex = raw.size - 16 + index
                        if (sourceIndex in raw.indices) raw[sourceIndex] else 0
                    }
                }
                val address = InetAddress.getByAddress(bytes).hostAddress ?: "::"
                results.add(address to depth)
                return
            }
            if (node.isExcluded) return
            collect(node.left, currentIp, depth + 1)
            collect(node.right, currentIp.or(one.shiftLeft(127 - depth)), depth + 1)
        }
        collect(root, BigInteger.ZERO, 0)
        return results
    }
}
