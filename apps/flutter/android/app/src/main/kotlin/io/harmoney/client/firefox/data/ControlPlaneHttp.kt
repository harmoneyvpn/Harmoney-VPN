package io.harmoney.client.firefox.data

import okhttp3.Cookie
import okhttp3.CookieJar
import okhttp3.HttpUrl
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.FilterOutputStream
import java.io.OutputStream
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.Socket
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.TimeUnit
import javax.net.SocketFactory

// Match FoxyVPN's desktop client identity which Mozilla's VPN control plane accepts.
const val MOZILLA_VPN_USER_AGENT = "MozillaVPN/2.35.0 (sys:linux; iap:true)"

fun Request.Builder.applyMozillaVpnHeaders(): Request.Builder {
    header("User-Agent", MOZILLA_VPN_USER_AGENT)
    header("Accept", "application/json")
    return this
}

fun Request.Builder.applyFirefoxHeaders(): Request.Builder = FirefoxAccountHeaders.apply(this)

class SimpleCookieJar : CookieJar {
    private val cookies = mutableListOf<Cookie>()

    @Synchronized
    override fun saveFromResponse(url: HttpUrl, cookies: List<Cookie>) {
        for (cookie in cookies) {
            this.cookies.removeAll {
                it.name == cookie.name && it.domain == cookie.domain && it.path == cookie.path
            }
            if (cookie.expiresAt > System.currentTimeMillis()) this.cookies.add(cookie)
        }
    }

    @Synchronized
    override fun loadForRequest(url: HttpUrl): List<Cookie> {
        cookies.removeAll { it.expiresAt <= System.currentTimeMillis() }
        return cookies
            .filter { it.matches(url) }
            .sortedByDescending { it.domain.length }
            .distinctBy { it.name }
    }

    @Synchronized
    fun set(name: String, value: String, domain: String) {
        cookies.removeAll { it.name == name && it.domain == domain }
        cookies.add(
            Cookie.Builder()
                .name(name)
                .value(value)
                .domain(domain)
                .path("/")
                .expiresAt(Long.MAX_VALUE)
                .build(),
        )
    }

    @Synchronized
    fun snapshotAll(): List<Cookie> = cookies.toList()

    @Synchronized
    fun clear() {
        cookies.clear()
    }

    @Synchronized
    fun syncFromWebView(
        urls: List<String> = listOf(
            "https://accounts.firefox.com",
            "https://api.accounts.firefox.com",
            "https://oauth.accounts.firefox.com",
            "https://vpn.mozilla.org",
        ),
    ) {
        val manager = runCatching { android.webkit.CookieManager.getInstance() }.getOrNull() ?: return
        for (urlStr in urls) {
            val httpUrl = urlStr.toHttpUrlOrNull() ?: continue
            val cookieHeader = runCatching { manager.getCookie(urlStr) }.getOrNull() ?: continue
            val parsedCookies = mutableListOf<Cookie>()
            for (raw in cookieHeader.split(";")) {
                val trimmed = raw.trim()
                if (trimmed.isEmpty()) continue
                val eqIdx = trimmed.indexOf('=')
                if (eqIdx <= 0) continue
                val name = trimmed.substring(0, eqIdx).trim()
                val value = trimmed.substring(eqIdx + 1).trim()
                if (name.isEmpty() || value.isEmpty()) continue

                val hostCookie = runCatching {
                    Cookie.Builder()
                        .name(name)
                        .value(value)
                        .domain(httpUrl.host)
                        .path("/")
                        .apply { if (httpUrl.isHttps) secure() }
                        .build()
                }.getOrNull()
                if (hostCookie != null) parsedCookies.add(hostCookie)

                if (httpUrl.host.endsWith("firefox.com") && httpUrl.host != "firefox.com") {
                    val domainCookie = runCatching {
                        Cookie.Builder()
                            .name(name)
                            .value(value)
                            .domain("firefox.com")
                            .path("/")
                            .apply { if (httpUrl.isHttps) secure() }
                            .build()
                    }.getOrNull()
                    if (domainCookie != null) parsedCookies.add(domainCookie)
                    for (target in listOf("api.accounts.firefox.com", "oauth.accounts.firefox.com", "vpn.mozilla.org")) {
                        val targetCookie = runCatching {
                            Cookie.Builder()
                                .name(name)
                                .value(value)
                                .domain(target)
                                .path("/")
                                .apply { if (httpUrl.isHttps) secure() }
                                .build()
                        }.getOrNull()
                        if (targetCookie != null) parsedCookies.add(targetCookie)
                    }
                }
            }
            if (parsedCookies.isNotEmpty()) {
                saveFromResponse(httpUrl, parsedCookies)
            }
        }
    }

    @Synchronized
    fun syncToWebView(cookies: List<Cookie>) {
        val manager = runCatching { android.webkit.CookieManager.getInstance() }.getOrNull() ?: return
        for (cookie in cookies) {
            val host = cookie.domain.trimStart('.')
            if (host.isEmpty()) continue
            val urlStr = "https://$host"
            val cookieString = StringBuilder().apply {
                append(cookie.name).append("=").append(cookie.value)
                append("; Domain=").append(cookie.domain)
                append("; Path=").append(cookie.path)
                if (cookie.secure) append("; Secure")
                if (cookie.httpOnly) append("; HttpOnly")
            }.toString()
            runCatching { manager.setCookie(urlStr, cookieString) }
        }
        runCatching { manager.flush() }
    }
}

/**
 * Mirrors FoxyVPN's FIRST_BYTE TLS fragmentation for Firefox control-plane
 * requests. Some networks reject the FxA API ClientHello while serving the
 * ordinary accounts web page, which otherwise leaves the login flow with an
 * empty HTTP 406 and no challenge body to solve.
 */
private class SplitClientHelloSocket : Socket() {
    private var splitDone = false

    override fun getOutputStream(): OutputStream {
        val socketOutput = super.getOutputStream()
        return object : FilterOutputStream(socketOutput) {
            override fun write(bytes: ByteArray, offset: Int, length: Int) {
                if (splitDone || !looksLikeClientHello(bytes, offset, length)) {
                    socketOutput.write(bytes, offset, length)
                    return
                }

                splitDone = true
                tcpNoDelay = true
                socketOutput.write(bytes, offset, 1)
                socketOutput.flush()
                socketOutput.write(bytes, offset + 1, length - 1)
                socketOutput.flush()
            }
        }
    }

    private fun looksLikeClientHello(bytes: ByteArray, offset: Int, length: Int): Boolean =
        length >= 6 && offset + length <= bytes.size &&
            bytes[offset] == 0x16.toByte() &&
            bytes[offset + 1] == 0x03.toByte() &&
            bytes[offset + 5] == 0x01.toByte()
}

private class ProtectingSocketFactory : SocketFactory() {
    private fun protect(socket: Socket): Socket {
        if (ControlPlaneHttp.socketProtector?.invoke(socket) == false) {
            socket.close()
            throw java.io.IOException("Could not bind a protected physical-network socket")
        }
        return socket
    }

    override fun createSocket(): Socket = protect(SplitClientHelloSocket())

    override fun createSocket(host: String, port: Int): Socket =
        protect(SplitClientHelloSocket()).apply { connect(InetSocketAddress(host, port)) }

    override fun createSocket(host: String, port: Int, localAddr: InetAddress, localPort: Int): Socket =
        protect(SplitClientHelloSocket()).apply {
            bind(InetSocketAddress(localAddr, localPort))
            connect(InetSocketAddress(host, port))
        }

    override fun createSocket(host: InetAddress, port: Int): Socket =
        protect(SplitClientHelloSocket()).apply { connect(InetSocketAddress(host, port)) }

    override fun createSocket(host: InetAddress, port: Int, localAddr: InetAddress, localPort: Int): Socket =
        protect(SplitClientHelloSocket()).apply {
            bind(InetSocketAddress(localAddr, localPort))
            connect(InetSocketAddress(host, port))
        }
}

object ControlPlaneHttp {
    val cookieJar = SimpleCookieJar()

    @Volatile
    var socketProtector: ((Socket) -> Boolean)? = null

    val client: OkHttpClient by lazy {
        OkHttpClient.Builder()
            .cookieJar(cookieJar)
            .socketFactory(ProtectingSocketFactory())
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .callTimeout(30, TimeUnit.SECONDS)
            .build()
    }
}
