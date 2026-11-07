package io.harmoney.client

/** Prefer validated physical paths, but allow restricted mobile networks. */
internal object PhysicalNetworkPolicy {
    fun rank(internet: Boolean, vpn: Boolean, validated: Boolean, wifi: Boolean): Int {
        if (!internet || vpn) return -1
        return (if (validated) 2 else 0) + (if (wifi) 1 else 0)
    }
}
