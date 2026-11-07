package io.harmoney.client

import android.content.Context

/** Localizes native foreground-service notification text using Flutter's saved app locale. */
object VpnNotificationLocalizer {
    private val supported = setOf("fa", "en", "ar", "tr", "ru", "zh", "fr", "de", "es", "it")

    fun text(context: Context, source: String): String {
        val saved = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .getString("flutter.locale", "fa")?.substringBefore('-')?.lowercase() ?: "fa"
        val language = saved.takeIf { it in supported } ?: "en"
        val bilingual = source.split(" / ", limit = 2)
        val english = if (bilingual.size == 2) bilingual[1] else source
        val persianOnly = bilingual.size == 1 && language == "fa"
        if (persianOnly) return source
        if (language == "it") return italian(english, source)

        val values = when {
            english.startsWith("Connecting with ") -> {
                val protocol = english.removePrefix("Connecting with ")
                listOf("در حال اتصال با $protocol…", "Connecting with $protocol…", "جارٍ الاتصال عبر $protocol…", "$protocol ile bağlanılıyor…", "Подключение через $protocol…", "正在通过 $protocol 连接…", "Connexion à $protocol…", "Verbinde mit $protocol…", "Conectando con $protocol…")
            }
            english.endsWith(" active, verifying…") -> {
                val protocol = english.removeSuffix(" active, verifying…")
                listOf("$protocol فعال است؛ در حال بررسی…", "$protocol active, verifying…", "$protocol نشط، جارٍ التحقق…", "$protocol etkin, doğrulanıyor…", "$protocol активен, проверка…", "$protocol 已启用，正在验证…", "$protocol actif, vérification…", "$protocol aktiv, wird überprüft…", "$protocol activo, verificando…")
            }
            english.endsWith(" connected") && !english.startsWith("Connected") -> {
                val protocol = english.removeSuffix(" connected")
                listOf("$protocol متصل شد", "$protocol connected", "تم الاتصال عبر $protocol", "$protocol bağlandı", "$protocol подключен", "$protocol 已连接", "$protocol connecté", "$protocol verbunden", "$protocol conectado")
            }
            english == "Connected · verified" -> listOf("متصل · تأیید شد", "Connected · verified", "متصل · تم التحقق", "Bağlandı · doğrulandı", "Подключено · проверено", "已连接 · 已验证", "Connecté · vérifié", "Verbunden · bestätigt", "Conectado · verificado")
            english.startsWith("Connected · ") -> {
                val detail = english.removePrefix("Connected · ")
                listOf("متصل · $detail", "Connected · $detail", "متصل · $detail", "Bağlandı · $detail", "Подключено · $detail", "已连接 · $detail", "Connecté · $detail", "Verbunden · $detail", "Conectado · $detail")
            }
            english.startsWith("Connected • ") -> {
                val detail = english.removePrefix("Connected • ")
                listOf("متصل • $detail", "Connected • $detail", "متصل • $detail", "Bağlandı • $detail", "Подключено • $detail", "已连接 • $detail", "Connecté • $detail", "Verbunden • $detail", "Conectado • $detail")
            }
            english.startsWith("Proxy active • ") -> {
                val detail = english.removePrefix("Proxy active • ")
                listOf("پراکسی فعال • $detail", "Proxy active • $detail", "الوكيل نشط • $detail", "Proxy etkin • $detail", "Прокси активен • $detail", "代理已启用 • $detail", "Proxy actif • $detail", "Proxy aktiv • $detail", "Proxy activo • $detail")
            }
            english.startsWith("Checking route: ") -> {
                val detail = english.removePrefix("Checking route: ")
                listOf("در حال بررسی مسیر: $detail", "Checking route: $detail", "جارٍ فحص المسار: $detail", "Rota denetleniyor: $detail", "Проверка маршрута: $detail", "正在检查线路：$detail", "Vérification de la route : $detail", "Route wird geprüft: $detail", "Comprobando ruta: $detail")
            }
            english == "Connecting…" -> listOf("در حال اتصال…", "Connecting…", "جارٍ الاتصال…", "Bağlanıyor…", "Подключение…", "正在连接…", "Connexion…", "Verbindung wird hergestellt…", "Conectando…")
            english == "Finding a route…" -> listOf("در حال یافتن مسیر…", "Finding a route…", "جارٍ العثور على مسار…", "Rota aranıyor…", "Поиск маршрута…", "正在查找线路…", "Recherche d'une route…", "Route wird gesucht…", "Buscando una ruta…")
            english == "Verifying tunnel…" -> listOf("در حال بررسی تونل…", "Verifying tunnel…", "جارٍ التحقق من النفق…", "Tünel doğrulanıyor…", "Проверка туннеля…", "正在验证隧道…", "Vérification du tunnel…", "Tunnel wird überprüft…", "Verificando túnel…")
            english == "Rechecking tunnel…" -> listOf("در حال بررسی دوباره تونل…", "Rechecking tunnel…", "جارٍ إعادة فحص النفق…", "Tünel yeniden denetleniyor…", "Повторная проверка туннеля…", "正在重新检查隧道…", "Nouvelle vérification du tunnel…", "Tunnel wird erneut geprüft…", "Revisando el túnel…")
            english == "Connection failed" -> listOf("اتصال ناموفق", "Connection failed", "فشل الاتصال", "Bağlantı başarısız", "Не удалось подключиться", "连接失败", "Échec de la connexion", "Verbindung fehlgeschlagen", "Error de conexión")
            english == "Disconnecting…" -> listOf("در حال قطع اتصال…", "Disconnecting…", "جارٍ قطع الاتصال…", "Bağlantı kesiliyor…", "Отключение…", "正在断开连接…", "Déconnexion…", "Verbindung wird getrennt…", "Desconectando…")
            english == "Disconnected" -> listOf("قطع شد", "Disconnected", "تم قطع الاتصال", "Bağlantı kesildi", "Отключено", "已断开连接", "Déconnecté", "Getrennt", "Desconectado")
            english == "VPN connection" -> listOf("اتصال VPN", "VPN connection", "اتصال VPN", "VPN bağlantısı", "VPN-подключение", "VPN 连接", "Connexion VPN", "VPN-Verbindung", "Conexión VPN")
            english == "Waiting for network…" -> listOf("در انتظار شبکه…", "Waiting for network…", "في انتظار الشبكة…", "Ağ bekleniyor…", "Ожидание сети…", "正在等待网络…", "En attente du réseau…", "Warte auf Netzwerk…", "Esperando la red…")
            english == "Reconnecting…" -> listOf("در حال اتصال دوباره…", "Reconnecting…", "جارٍ إعادة الاتصال…", "Yeniden bağlanıyor…", "Повторное подключение…", "正在重新连接…", "Reconnexion…", "Verbindung wird wiederhergestellt…", "Reconectando…")
            source.startsWith("در حال اتصال Cisco") -> listOf("در حال اتصال Cisco", "Connecting to Cisco VPN…", "جارٍ الاتصال بشبكة Cisco…", "Cisco ağına bağlanılıyor…", "Подключение к Cisco VPN…", "正在连接 Cisco VPN…", "Connexion au VPN Cisco…", "Verbindung mit Cisco VPN…", "Conectando a Cisco VPN…")
            source.startsWith("متصل به ") -> {
                val name = source.removePrefix("متصل به ")
                listOf(source, "Connected to $name", "متصل بـ $name", "$name ağına bağlandı", "Подключено к $name", "已连接到 $name", "Connecté à $name", "Verbunden mit $name", "Conectado a $name")
            }
            else -> return source
        }
        return values[listOf("fa", "en", "ar", "tr", "ru", "zh", "fr", "de", "es").indexOf(language)]
    }

    fun disconnect(context: Context): String {
        val saved = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .getString("flutter.locale", "fa")?.substringBefore('-')?.lowercase() ?: "fa"
        val language = saved.takeIf { it in supported } ?: "en"
        return when (language) {
            "fa" -> "قطع اتصال"
            "ar" -> "قطع الاتصال"
            "tr" -> "Bağlantıyı kes"
            "ru" -> "Отключиться"
            "zh" -> "断开连接"
            "fr" -> "Déconnecter"
            "de" -> "Trennen"
            "es" -> "Desconectar"
            "it" -> "Disconnetti"
            else -> "Disconnect"
        }
    }

    private fun italian(english: String, source: String): String = when {
        english == "Connected · verified" -> "Connesso · verificato"
        english.startsWith("Connecting with ") -> "Connessione a ${english.removePrefix("Connecting with ")}…"
        english.endsWith(" active, verifying…") -> "${english.removeSuffix(" active, verifying…")} attivo, verifica in corso…"
        english.endsWith(" connected") && !english.startsWith("Connected") -> "${english.removeSuffix(" connected")} connesso"
        english.startsWith("Connected · ") -> "Connesso · ${english.removePrefix("Connected · ")}"
        english.startsWith("Connected • ") -> "Connesso • ${english.removePrefix("Connected • ")}"
        english.startsWith("Proxy active • ") -> "Proxy attivo • ${english.removePrefix("Proxy active • ")}"
        english.startsWith("Checking route: ") -> "Verifica percorso: ${english.removePrefix("Checking route: ")}"
        english == "Connecting…" -> "Connessione…"
        english == "Finding a route…" -> "Ricerca di un percorso…"
        english == "Verifying tunnel…" -> "Verifica del tunnel…"
        english == "Rechecking tunnel…" -> "Nuova verifica del tunnel…"
        english == "Connection failed" -> "Connessione non riuscita"
        english == "Disconnecting…" -> "Disconnessione…"
        english == "Disconnected" -> "Disconnesso"
        english == "VPN connection" -> "Connessione VPN"
        english == "Waiting for network…" -> "In attesa della rete…"
        english == "Reconnecting…" -> "Riconnessione…"
        source.startsWith("در حال اتصال Cisco") -> "Connessione a Cisco VPN…"
        source.startsWith("متصل به ") -> "Connesso a ${source.removePrefix("متصل به ")}"
        else -> source
    }
}
