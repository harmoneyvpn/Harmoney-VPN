package io.harmoney.client

import org.json.JSONObject

internal object HarmoneyRouteConfig {
    val patterns = setOf("auto", "fastlane", "xray", "masque", "warp", "gool")
    fun cacheName(route: String, networkKey: String, flowDigest: String): String =
        if (route in setOf("masque", "warp", "gool")) "harmoney-$route"
        else "harmoney-$route-$networkKey-$flowDigest"
    fun autoPatterns(enabledLabels: Collection<String>, cellular: Boolean): List<String> {
        val enabled = enabledLabels.map { it.lowercase() }.toSet()
        // Public Xray paths succeeded on the tested mobile carrier while
        // Cloudflare transports failed. Auto still verifies each real route.
        val order = if (cellular) listOf("fastlane", "xray", "masque", "warp", "gool")
            else listOf("masque", "xray", "fastlane", "warp", "gool")
        return order.filter { it in enabled }
    }

    fun plan(source: String, pattern: String, cellular: Boolean): List<String> {
        require(pattern in patterns) { "Invalid Harmoney route" }
        if (pattern != "auto") return listOf(pattern)
        val groups = JSONObject(source).getJSONArray("flowLine")
        val enabled = (0 until groups.length()).map { groups.getJSONObject(it) }
            .filter { it.optBoolean("enabled") }.map { it.getString("label") }
        return autoPatterns(enabled, cellular).also {
            check(it.isNotEmpty()) { "Harmoney auto has no enabled routes" }
        }
    }
    fun select(source: String, pattern: String): Pair<String, String> {
        require(pattern in patterns) { "Invalid Harmoney route" }
        val data = JSONObject(source)
        val groups = data.getJSONArray("flowLine")
        val selected = mutableListOf<String>()
        for (i in 0 until groups.length()) {
            val group = groups.getJSONObject(i)
            val label = group.getString("label")
            val enabled = if (pattern == "auto") group.optBoolean("enabled")
                else label.equals(pattern, ignoreCase = true)
            group.put("enabled", enabled)
            if (enabled) selected += label
        }
        check(selected.isNotEmpty()) { "Harmoney route has no configured transport" }
        // Public Fastlane exits can reject IPv6; MASQUE is the stable default.
        if (pattern == "auto") selected.sortBy { when (it.lowercase()) {
            "masque" -> 0; "xray" -> 1; else -> 2
        } }
        return data.toString() to selected.joinToString(",")
    }
}
