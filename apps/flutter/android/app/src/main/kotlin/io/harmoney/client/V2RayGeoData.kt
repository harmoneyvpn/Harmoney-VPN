package io.harmoney.client

import com.google.protobuf.CodedInputStream
import com.google.protobuf.WireFormat
import java.net.InetAddress
import java.util.Locale

/** Reads V2Ray/Xray GeoIPList and GeoSiteList protobuf data without bundling a VPN core. */
internal object V2RayGeoData {
    data class IpRules(val ipv4: List<String>, val ipv6: List<String>)

    fun readCountry(bytes: ByteArray, country: String): IpRules {
        require(bytes.size in 1..8_000_000) { "Invalid GeoIP DAT size" }
        val input = CodedInputStream.newInstance(bytes)
        val ipv4 = linkedSetOf<String>()
        val ipv6 = linkedSetOf<String>()
        var found = false
        while (!input.isAtEnd) {
            val tag = input.readTag()
            if (tag == 0) break
            if (WireFormat.getTagFieldNumber(tag) != 1 || WireFormat.getTagWireType(tag) != 2) {
                input.skipField(tag)
                continue
            }
            val entry = CodedInputStream.newInstance(input.readByteArray())
            var code = ""
            val candidateV4 = mutableListOf<String>()
            val candidateV6 = mutableListOf<String>()
            while (!entry.isAtEnd) {
                val entryTag = entry.readTag()
                if (entryTag == 0) break
                when (WireFormat.getTagFieldNumber(entryTag)) {
                    1 -> code = entry.readStringRequireUtf8()
                    2 -> {
                        val cidr = readCidr(entry.readByteArray())
                        if (cidr != null) {
                            if (cidr.first == 4) candidateV4.add(cidr.second)
                            else candidateV6.add(cidr.second)
                        }
                    }
                    else -> entry.skipField(entryTag)
                }
            }
            if (code.equals(country, ignoreCase = true)) {
                found = true
                ipv4.addAll(candidateV4)
                ipv6.addAll(candidateV6)
            }
        }
        require(found && ipv4.isNotEmpty()) { "GeoIP DAT has no IPv4 rules for $country" }
        return IpRules(ipv4.toList(), ipv6.toList())
    }

    private fun readCidr(bytes: ByteArray): Pair<Int, String>? {
        val input = CodedInputStream.newInstance(bytes)
        var ip = byteArrayOf()
        var prefix = -1
        while (!input.isAtEnd) {
            val tag = input.readTag()
            if (tag == 0) break
            when (WireFormat.getTagFieldNumber(tag)) {
                1 -> ip = input.readByteArray()
                2 -> prefix = input.readUInt32()
                else -> input.skipField(tag)
            }
        }
        if (ip.size != 4 && ip.size != 16) return null
        if (prefix !in 0..(ip.size * 8)) return null
        val canonical = ip.copyOf()
        for (bit in prefix until (ip.size * 8)) {
            val index = bit / 8
            canonical[index] = (canonical[index].toInt() and (1 shl (7 - bit % 8)).inv()).toByte()
        }
        return ip.size to "${InetAddress.getByAddress(canonical).hostAddress}/$prefix"
    }

    /** Parse only the IR section. Plain/regex rules are intentionally not treated as suffixes. */
    fun readIranianDomains(bytes: ByteArray): Set<String> {
        require(bytes.size in 1..8_000_000) { "Invalid GeoSite DAT size" }
        val input = CodedInputStream.newInstance(bytes)
        val domains = linkedSetOf<String>()
        var found = false
        while (!input.isAtEnd) {
            val tag = input.readTag()
            if (tag == 0) break
            if (WireFormat.getTagFieldNumber(tag) != 1 || WireFormat.getTagWireType(tag) != 2) {
                input.skipField(tag)
                continue
            }
            val entry = CodedInputStream.newInstance(input.readByteArray())
            var code = ""
            val candidate = mutableListOf<String>()
            while (!entry.isAtEnd) {
                val entryTag = entry.readTag()
                if (entryTag == 0) break
                when (WireFormat.getTagFieldNumber(entryTag)) {
                    1 -> code = entry.readStringRequireUtf8()
                    2 -> {
                        val rule = CodedInputStream.newInstance(entry.readByteArray())
                        var type = 0
                        var value = ""
                        while (!rule.isAtEnd) {
                            val ruleTag = rule.readTag()
                            if (ruleTag == 0) break
                            when (WireFormat.getTagFieldNumber(ruleTag)) {
                                1 -> type = rule.readEnum()
                                2 -> value = rule.readStringRequireUtf8()
                                else -> rule.skipField(ruleTag)
                            }
                        }
                        if (type == 2 || type == 3) {
                            val domain = value.lowercase(Locale.US).trimEnd('.')
                            if (domain.isNotBlank() && !domain.contains(' ')) candidate.add(domain)
                        }
                    }
                    else -> entry.skipField(entryTag)
                }
            }
            if (code.equals("IR", ignoreCase = true)) {
                found = true
                domains.addAll(candidate)
            }
        }
        require(found && domains.isNotEmpty()) { "GeoSite DAT has no IR domains" }
        return domains
    }
}
