// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Harmoney VPN';

  @override
  String get splashSubtitle => 'Güvenli internet erişimi için tasarlandı,\nherkes için, her yerde';

  @override
  String get connect => 'Bağlan';

  @override
  String get disconnect => 'Bağlantıyı Kes';

  @override
  String get connected => 'Bağlandı';

  @override
  String get disconnected => 'Bağlantı Kesildi';

  @override
  String get connecting => 'Bağlanıyor';

  @override
  String connectingVia(String groupName) {
    return '$groupName üzerinden bağlanılıyor';
  }

  @override
  String get switchingMethod => 'YÖNTEM DEĞİŞTİRİLİYOR';

  @override
  String get speedTest => 'Hız Testi';

  @override
  String get download => 'İNDİRME';

  @override
  String get upload => 'YÜKLEME';

  @override
  String get ping => 'PİNG';

  @override
  String get latency => 'GECİKME';

  @override
  String get jitter => 'DALGALANMA';

  @override
  String get packetLoss => 'PAKET KAYBI';

  @override
  String get tapHere => 'BURAYA DOKUNUN';

  @override
  String get settings => 'Ayarlar';

  @override
  String get introduction => 'Giriş';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get termsAndConditions => 'Şartlar ve Koşullar';

  @override
  String get ourWebsite => 'Web Sitemiz';

  @override
  String get marketplace => 'Pazar Yeri';

  @override
  String get telegramBot => 'Telegram Botu';

  @override
  String get sourceCode => 'Kaynak Kodu';

  @override
  String get openSourceLicenses => 'Açık Kaynak Lisansları';

  @override
  String get betaCommunity => 'Beta Topluluğu';

  @override
  String get close => 'Kapat';

  @override
  String get copyLogs => 'Günlükleri Kopyala';

  @override
  String get logsCopied => 'Günlükler panoya kopyalandı';

  @override
  String get appLogs => 'Uygulama Günlükleri';

  @override
  String get autoRefresh => 'Otomatik Yenile';

  @override
  String get clear => 'Temizle';

  @override
  String get quickMenu => 'Hızlı Menü';

  @override
  String get noInternet => 'İnternet Yok';

  @override
  String get error => 'Hata';

  @override
  String get loading => 'Yükleniyor';

  @override
  String get analyzing => 'Analiz Ediliyor';

  @override
  String get mbps => 'Mbps';

  @override
  String get ms => 'ms';

  @override
  String get language => 'Dil';

  @override
  String get tips => 'İPUÇLARI';

  @override
  String get english => 'İngilizce';

  @override
  String get chinese => '中文 (Çince)';

  @override
  String get gotIt => 'Anladım';

  @override
  String get learnMore => 'DAHA FAZLA BİLGİ EDİNİN';

  @override
  String get harmoneyGoal => 'Harmoney\'nin amacı, kamuya açık bilgilere güvenli erişim sağlamak ve ücretsiz bir tarama deneyimi sağlamaktır.';

  @override
  String get statusIsChilling => 'tüyler ürpertici.';

  @override
  String get statusIs => ',';

  @override
  String get statusFailed => 'başarısız oldu.';

  @override
  String get statusHas => '';

  @override
  String get statusIsReturning => ',';

  @override
  String get statusToStandbyMode => '\'yi bekleme moduna döndürüyor.';

  @override
  String get statusPluggingIn => 'takılıyor ...';

  @override
  String get statusPoweredUp => 'çalıştırılıyor';

  @override
  String get statusDoingScience => 'bilim yapıyorum...';

  @override
  String get statusExitedMatrix => '';

  @override
  String get statusSorry => 'matrisinden çıktık özür dileriz :(';

  @override
  String get statusConnectAlready => 'Zaten bağlanın';

  @override
  String get statusTestingSpeed => 'test hızı...';

  @override
  String get statusIsReady => 'hazır';

  @override
  String get statusIsInTrouble => '\'nin başı dertte.';

  @override
  String get statusDXcoreDown => 'DXcore aşağı.';

  @override
  String get statusToSpeedTest => 'hız testi için';

  @override
  String get statusYoursToShape => 'sizin şekillendirmeniz için';

  @override
  String get settingsConnectionMethod => 'BAĞLANTI YÖNTEMİ';

  @override
  String get settingsEscapeMode => 'KAÇIŞ MODU';

  @override
  String get settingsDestination => 'HEDEF';

  @override
  String get settingsSplitTunnel => 'Bölünmüş Tünel';

  @override
  String get settingsKillSwitch => 'Acil Durum Kesicisi';

  @override
  String get settingsDeepScan => 'DERİN TARAMA';

  @override
  String get settingsHealthCheck => 'SAĞLIK KONTROLÜ';

  @override
  String get settingsIncluded => 'DAHİL';

  @override
  String get settingsAtLeastOneCoreRequired => 'En az bir çekirdek etkin kalmalıdır';

  @override
  String get settingsResetToDefault => 'RESET';

  @override
  String get offlineFlowlineMessage => 'Çevrimdışı sürüm şu anda kullanıldığından Flowline güncellemeleri duraklatıldı.';

  @override
  String get offlineFlowlineUndo => 'GERİ AL';

  @override
  String get updateAvailable => 'Güncelleme mevcut';

  @override
  String get updateRequired => 'Güncelleme gerekli';

  @override
  String get updateOptionalMessage => 'Uygulamadan en iyi şekilde yararlanmak ve en son iyileştirmelerin keyfini çıkarmak için lütfen en yeni sürüme güncelleyin.';

  @override
  String get updateRequiredMessage => 'Harmoney\'yi kullanmaya devam etmek için lütfen en son sürüme güncelleyin. Bu güncelleme kritik iyileştirmeler içerir ve uygulamanın işlevselliği için gereklidir.';

  @override
  String get updateNow => 'Şimdi güncelle';

  @override
  String get notNow => 'Şimdi değil';

  @override
  String get updateMethods => 'Güncelleme Yöntemleri';

  @override
  String get importConfig => 'Yapılandırmayı İçe Aktar';

  @override
  String get synchronization => 'Senkronizasyon';

  @override
  String get settingsDonation => 'Bağış';

  @override
  String get settingsDonationDescription => 'Dijital sansürün ve internet filtrelemenin duvarlarını yıkmamıza yardımcı olun.';

  @override
  String get authenticationRequired => 'Kimlik Doğrulaması Gerekli';

  @override
  String get premiumLoginDescription => 'Premium aboneliklerinize erişmek için, Harmoney web sitesi aracılığıyla oturum açmanız veya bir hesap oluşturmanız gerekir.';

  @override
  String get email => 'E-posta';

  @override
  String get emailHint => 'example@domain.com';

  @override
  String get emailValidation => 'Lütfen e-posta adresinizi girin';

  @override
  String get password => 'Şifre';

  @override
  String get passwordHint => 'Şifrenizi girin';

  @override
  String get passwordValidation => 'Lütfen şifrenizi girin';

  @override
  String get passwordMinLength => 'Şifre en az 6 karakterden oluşmalıdır';

  @override
  String get login => 'Giriş Yap';

  @override
  String get noAccount => 'Hesabınız yok mu?';

  @override
  String get signUp => 'Kayıt ol';

  @override
  String get loginFailed => 'Giriş başarısız oldu. Lütfen kimlik bilgilerinizi kontrol edip tekrar deneyin.';

  @override
  String get loginSuccess => 'Giriş başarılı!';

  @override
  String get code => 'Kodu';

  @override
  String get codeHint => 'Erişim kodunuzu giriniz';

  @override
  String get codeValidation => 'Lütfen kodunuzu giriniz';

  @override
  String get premiumLoginByCodeDescription => 'Premium aboneliklerinize erişmek için size verilen erişim kodunu girin.';

  @override
  String get havingTrouble => 'Sorun mu yaşıyorsunuz?';

  @override
  String get signedInAs => 'Şu anda';

  @override
  String get premiumImportDescription => 'e-posta adresiyle oturum açmış durumdasınız. Premium abonelikleriniz internet kısıtlamaları nedeniyle yüklenemiyorsa ve mevcut yöntemleri kullanarak bağlanamıyorsanız Marketplace\'ten aldığınız dosyayı uygulamaya aktarabilirsiniz.';

  @override
  String get planningToExit => 'Çıkmayı mı planlıyorsunuz?';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get signOutSuccess => 'Başarıyla çıkış yapıldı!';

  @override
  String get settingsMarketplace => 'Pazaryeri';

  @override
  String get marketplaceDescription => 'Güvenilir tedarikçilerden gelen güvenli VPN yapılandırmalarına göz atın.';

  @override
  String get loggedIn => 'OTURUM AÇTI';

  @override
  String get loginOrRegister => 'OTURUM AÇIN VEYA KAYIT OLUN';

  @override
  String get loginByCode => 'Kodla giriş yapın';

  @override
  String get backToLoginByEmail => 'E-postayla girişe geri dönün';

  @override
  String get connectionRequired => 'Bağlantı Gerekli';

  @override
  String get connectionRequiredDescription => 'Güvenli bir giriş veya kayıt işlemini tamamlamak için, öncelikle mevcut bağlantı yöntemlerinden birini kullanarak bir bağlantı kurmalısınız.';

  @override
  String get inlineText_a5998db73b68af63 => 'Sunucu ayarları';

  @override
  String get inlineText_3305ac4300665f71 => 'Bu cihazın otomatik taranması';

  @override
  String get inlineText_fa7af603d430b209 => 'İptal';

  @override
  String get inlineText_9de2a0d933190a40 => 'Harmoney Pro';

  @override
  String get inlineText_9fd728c66c9a256b => 'Ekle';

  @override
  String get inlineText_8450d81a2ef331f0 => 'Bu platformda desteklenmiyor.';

  @override
  String get inlineText_6f759aed280d8ae1 => 'Donanım tanımlayıcısı sunucunun varsayılan değerine sıfırlandı.';

  @override
  String get inlineText_10ae58fbb5984f6e => 'Android ve Linux\'ta seçilen abonelik kullanılır, ancak VPN çekirdeği bundan farklı bir düğüm seçebilir.';

  @override
  String get inlineText_c01c4324f1fa14fc => 'İçe aktarılıyor…';

  @override
  String get inlineText_ef207787e1f5054a => 'Uygulama başına bypass bu platformda desteklenmiyor.';

  @override
  String get inlineText_543264e2f45dd255 => 'VPN';

  @override
  String get inlineText_034fc31b30e178f0 => 'Firefox VPN protokolü';

  @override
  String get inlineText_4fcf7e0d90445713 => 'Devre Dışı: Tüm trafik şifreli VPN tüneli üzerinden güvenli bir şekilde yönlendirilir.';

  @override
  String get inlineText_272a96114c7af32f => 'Özel Baypas Kuralları';

  @override
  String get inlineText_7b547a5ae60b2f38 => 'Firefox VPN';

  @override
  String get inlineText_4b42c738a9185fc5 => 'Erişim Noktası Etkin';

  @override
  String get inlineText_fa174cea0ac4357d => 'Tercihi kaydet';

  @override
  String get inlineText_5474eef8d0f179c7 => 'İşleniyor…';

  @override
  String get inlineText_e6f7f8ccc059e5c7 => 'Hiçbir uygulama seçilmedi.';

  @override
  String get inlineText_df8748e19fc6ee2b => 'Bağlantının kesilmesi beklenenden uzun sürüyor. Tekrar deneyebilirsiniz.';

  @override
  String get inlineText_c0bd827e34b175ab => 'İnternet Erişimini Engelle';

  @override
  String get inlineText_7af2f7454f3b55aa => 'Durumu ve kotayı yenile';

  @override
  String get inlineText_eea2745e2867a677 => 'Doğrulamak';

  @override
  String get inlineText_88712c434b491bce => 'Giriş Gerekli';

  @override
  String get inlineText_7d9eb7acb13e2462 => 'Kapat';

  @override
  String get inlineText_46b5d935b82dd8e0 => 'Bağlantı hizmetini seçin';

  @override
  String get inlineText_8035283793ddc0b5 => 'En son oturumu ve trafik kotasını sorgula';

  @override
  String get inlineText_64a985f51e17518b => 'Özel atlama kuralı yok.';

  @override
  String get inlineText_90e0e260530759ce => 'Yalnızca ana makine';

  @override
  String get inlineText_fa1cf54705b7a6ea => 'Cihaz Donanım Kimliğini Oluştur';

  @override
  String get inlineText_8693a5d72c6b23fa => 'Güvenli şifreli tüneli telefonlarla ve tabletlerle paylaşın';

  @override
  String get inlineText_0d21bd52022ca7f7 => 'Çevrimiçi';

  @override
  String get inlineText_7d096ae1ecf2a8cc => 'Bypass etme';

  @override
  String get inlineText_2fc9fc3695f14892 => 'Optimizasyonu Devre Dışı Bırak';

  @override
  String get inlineText_6405b0129cf5a714 => 'Oluşturulan son kimlik (SHA-256):';

  @override
  String get inlineText_5f65ccdf701bd499 => 'Ayarları Kaydet';

  @override
  String get inlineText_c90fdfab474bdd3e => 'Hesaba giriş yapın';

  @override
  String get inlineText_1c114a72bff7ecbc => 'ICS\'yi onarın';

  @override
  String get inlineText_c3a6d1c87fa8d4bb => 'Hız Testi Geçmişi';

  @override
  String get inlineText_4d9bfca28655ee45 => 'Oturum Yükleme:';

  @override
  String get inlineText_1a095c79818885e4 => 'Başlat Misafir';

  @override
  String get inlineText_d18f4156fea49644 => 'Hesap kontrol ediliyor…';

  @override
  String get inlineText_ac7c949f1211b781 => 'Etkin değil';

  @override
  String get inlineText_9c1ff072196e2d26 => 'Canlı yönlendirme ve güvenlik denetimleri gerçekleştirmeye hazır.';

  @override
  String get inlineText_df578dfdf0dafa9a => 'Henüz hız testi kaydedilmedi.';

  @override
  String get inlineText_5d6529256c6c68f0 => 'Doğrudan başlat';

  @override
  String get inlineText_23d5d93cf5f11e17 => 'Sınırsız kota';

  @override
  String get inlineText_1228cd974a4510cf => 'Sunucuları Dışa Aktarma';

  @override
  String get inlineText_0323bbb0e3e24d50 => 'IPv6\'e İzin Ver';

  @override
  String get inlineText_58e27854800bc94b => 'Ağ sıkışması çözüldü: Anahtarı, rotaları ve XFRM arayüzlerini normale döndürdü.';

  @override
  String get inlineText_d71035f8d7c85940 => 'Korumalı Erişim Noktası Seçenekleri';

  @override
  String get inlineText_14bd9f9fb68a5859 => 'VPN Sağlayıcısını Seçin';

  @override
  String get inlineText_cbca739d8ccd07e1 => 'XFRM arayüzünü, tablo 220\'yi, IP kurallarını inceleyin ve canlı bağlantıyı güvenli bir şekilde doğrulayın.';

  @override
  String get inlineText_d0527e4b3d658351 => 'Oturumu kapat';

  @override
  String get inlineText_f7fa281a488a9a0d => '50 GB';

  @override
  String get inlineText_a38c71d45d21c4ab => 'Yalnızca bilgilendir';

  @override
  String get inlineText_b8352b44a588721c => 'Uygulama dili';

  @override
  String get inlineText_e55142a1acfd8059 => 'Kullanıcı adı';

  @override
  String get inlineText_f2b10ce04701badc => 'Uygulamaları yükle';

  @override
  String get inlineText_b1fe69e5cd48a270 => '-- ms';

  @override
  String get inlineText_989961ec7fc20bdd => 'Android uygulama bypass\'ı, VPN yeniden bağlandıktan sonra uygulanır.';

  @override
  String get inlineText_039b675cbfc3719c => 'HTTP/2 BAĞLANTI';

  @override
  String get inlineText_7366b74aba11b666 => 'Konsol çıkışı panoya kopyalandı.';

  @override
  String get inlineText_0173658e5af8698d => 'Destek paketi dışa aktarıldı ve panoya kopyalandı.';

  @override
  String get inlineText_9f658c229a11bef6 => 'Mobil Erişim Noktası etkinken VPN bağdaştırıcısı için Windows ICS\'yi yapılandırır. Uygulama, ICS bağlanmasını doğrular; istemci İnternet trafiğinin hala uçtan uca kontrol edilmesi gerekiyor.';

  @override
  String get inlineText_73997b80ca90ece7 => 'Şu anda erişim noktasına bağlı cihaz yok.';

  @override
  String get inlineText_ebf5f31bd3fa8cf4 => 'Testi İptal Et';

  @override
  String get inlineText_4bfa799fae21b467 => 'Trafik Analizi';

  @override
  String get inlineText_b28b26cf1cc18caf => 'Daha sakin bir bağlantı. Daha parlak bir dünya.';

  @override
  String get inlineText_ed95556c5c93ded1 => 'Ülke ve Uygulama Atlama';

  @override
  String get inlineText_4cf9134d1c9ed485 => 'Bağlantı profillerinin çıktısı alınması';

  @override
  String get inlineText_2a78025de6aae5e7 => 'Seçme';

  @override
  String get inlineText_cbbea9d808ebfe70 => 'Surfshark';

  @override
  String get inlineText_88921e28030e4255 => 'Hizmet Şifresi / Özel Anahtar';

  @override
  String get inlineText_39c3183ee0cbb997 => 'Yapılandırılan gelişmiş ilke kuralı yok.';

  @override
  String get inlineText_6cb8a5b3137a00c3 => 'Seçilen ülke IP aralıkları VPN\'yi atlar. Kuralları değiştirdikten sonra yeniden bağlanın. Yalnızca etki alanı kuralları, DNS uyumlu yönlendirmeye ihtiyaç duyar.';

  @override
  String get inlineText_8bb1de2dfce6294f => 'Bağlantı başlatılıyor…';

  @override
  String get inlineText_22965568d22a14ee => 'Bağlı';

  @override
  String get inlineText_e7e2af717bdfb964 => 'Otomatik (Geri çekilme)';

  @override
  String get inlineText_42b5bc901ede1799 => '100 GB';

  @override
  String get inlineText_24ef681c569b5c42 => 'Sistem Uygulamaları';

  @override
  String get inlineText_3e2421c56094293c => 'Rota Tablosu ve XFRM Doğrulaması';

  @override
  String get inlineText_5d7cd082fc9987e9 => 'VPN Şifrelenmiş';

  @override
  String get inlineText_1159717463f1ebc3 => 'Hizmet Kullanıcı Adı / Anahtar Kimliği';

  @override
  String get inlineText_0e76960093379060 => 'Tarih';

  @override
  String get inlineText_cb0bf46bf1e385db => 'ZIP\'i içe aktar';

  @override
  String get inlineText_2da236423b3b5ad5 => 'Her Zaman Açık ve Kilitli kapak, VPN bağlantılarını destekler. DNS ve IPv6 politikaları etkin tünel tarafından uygulanır.';

  @override
  String get inlineText_50829e8639527356 => 'Uygulama ekle (.exe)';

  @override
  String get inlineText_f6f39fe075ffa5de => 'Uygulama atlama özelliğini etkinleştirmeden önce bir uygulama ekleyin.';

  @override
  String get inlineText_5a99f6fa7e98657a => 'QR\'yi tara';

  @override
  String get inlineText_c4b6bf5634f8ce91 => 'Bir hedefin neden kural önceliği eşleşmesi ile VPN veya Doğrudan ISP aracılığıyla yönlendirildiğini açıklayın.';

  @override
  String get inlineText_cf0883343f4abef7 => 'Protokol';

  @override
  String get inlineText_adec3733feabdc2d => 'Dosyalar başarıyla çıkarıldı.';

  @override
  String get inlineText_0c567745c63c57bc => 'Android, IPv4 ve IPv6 CIDR bypass\'ı destekler. Bu rotaları değiştirdikten sonra VPN\'yi yeniden bağlayın; uygulama atlama işlemi yeniden bağlandıktan sonra da etkili olur.';

  @override
  String get inlineText_cb0544450e1be874 => 'Denetleniyor…';

  @override
  String get inlineText_9e19b3ae1edc6135 => 'Android Kilitleme etkin';

  @override
  String get inlineText_0acb9208ef119b21 => 'Mobil Bağlantı Noktasını Aç';

  @override
  String get inlineText_61118b57b609e8fd => 'Bağlantıyı, güvenliği ve görünümü yönetin';

  @override
  String get inlineText_ed077f3d8125d60d => 'Açık';

  @override
  String get inlineText_bbf3d191d555c872 => 'Konumlar ve Rotalar';

  @override
  String get inlineText_c01d52ac9ed5701a => 'Harmoney Pro Bağlantı Hatası';

  @override
  String get inlineText_25a76b0a4ba5c39d => 'Güvenli Uygulama ve LKG';

  @override
  String get inlineText_967549497036d513 => 'Tüm seçimleri kaldır';

  @override
  String get inlineText_72a47f8e322a40de => 'Koruma HUD';

  @override
  String get inlineText_2398cc05005cca7f => 'Çevrimdışı önbelleğe hazır';

  @override
  String get inlineText_469f27ad0a12c557 => 'Bu kimlik, sunucudaki aygıtın kimliğini doğrulamak için donanım parmak izi (Hardware Device ID) olarak kullanılır. Değerleri değiştirebilir veya otomatik alabilirsiniz:';

  @override
  String get inlineText_783547972fe4ca08 => 'IKEv2';

  @override
  String get inlineText_03f15c48644862ae => 'Varsayılan Erişim Noktası Rotası';

  @override
  String get inlineText_bd5a05ddab828e6d => 'Başlat Konuk Wi-Fi';

  @override
  String get inlineText_4968fc7fef5ea571 => 'Kalan trafik:';

  @override
  String get inlineText_52a0bc5a1f46b6a1 => 'Firefox Hesabı';

  @override
  String get inlineText_bb93f3cc26e28600 => 'Otomatik süre sonu ve alt ağ izolasyonu ile geçici olarak izole edilmiş konuk Wi-Fi\'si.';

  @override
  String get inlineText_b361f42b64c263d8 => 'Güvenli kimlik bilgisi kasası denetleniyor…';

  @override
  String get inlineText_7d037fcb85b5a1eb => 'Doğrudan (VPN\'i Atla)';

  @override
  String get inlineText_e65731cec92db7d5 => 'Bir VPN işlemi zaten çalışıyor. Lütfen durumunun güncellenmesini bekleyin.';

  @override
  String get inlineText_f24d839a275e6eaa => 'Erişim Noktası Paylaşımını (ICS) Etkinleştir';

  @override
  String get inlineText_03a71a235bfb6b30 => 'Giriş başarılı oldu ve sunucu listesi güncellendi.';

  @override
  String get inlineText_52933373144828ee => 'Firefox Hesabı E-postası / Kullanıcı';

  @override
  String get inlineText_d86322c4ceb937de => 'Ülke IPv4 aralıkları, yeniden bağlandıktan sonra VPN\'yi atlar. Uygulama atlama, Windows fiziksel arayüzünü kullanır ve Harmoney hizmetini gerektirir.';

  @override
  String get inlineText_77f0b86ebfb47aa6 => 'Cihazın donanım kimliği başarıyla ayarlandı.';

  @override
  String get inlineText_35d7442440a55ab9 => 'Android\'in arka planda VPN bağlantısını kesmesini önlemek için bu uygulamanın pil optimizasyonunu devre dışı bırakın.';

  @override
  String get inlineText_3da7d703985421ec => 'Firefox veri tahsisi';

  @override
  String get inlineText_316f766fb0bc3a72 => 'Firefox VPN Hesabını Yönetin';

  @override
  String get inlineText_69b95013a9101213 => 'Gelişmiş Politika Kuralları';

  @override
  String get inlineText_9d0c59a66cf45b32 => 'VPN\'den sıcak noktaya ICS bağlanması doğrulandı.';

  @override
  String get inlineText_7ae00a283ea9b728 => 'Oturumun Süresi Doldu';

  @override
  String get inlineText_0dd786510199ca80 => 'Hizmet bağlantı ayarları';

  @override
  String get inlineText_708e318e0225bc88 => 'Misafiri Durdur';

  @override
  String get inlineText_ad4b77a68783ec24 => 'Oturum Süresi';

  @override
  String get inlineText_25dcc872936aab98 => 'Firefox Hesabı kimlik bilgileri yerel Windows yardımcısı tarafından doğrudan Mozilla\'ya gönderilir. Parola kaydedilmez; yalnızca gelecekteki bağlantılar için gereken hesap belirteçleri yerel olarak depolanır.';

  @override
  String get inlineText_219113c4bbe2e98c => 'Windows uygulama başına atlama, seçilen uygulamaları etkin VPN protokolünden bağımsız olarak doğrudan fiziksel bağdaştırıcı aracılığıyla yönlendirir. Windows derleme desteği ve ayrıcalıklı Harmoney hizmeti gereklidir.';

  @override
  String get inlineText_21e3324fcec20e63 => '0 GB (Kapalı)';

  @override
  String get inlineText_20636a0c41a3f954 => 'Gelişmiş Yönlendirme ve Koruma';

  @override
  String get inlineText_dc8bf418d2bb68a6 => 'Güvenli VPN DNS';

  @override
  String get inlineText_a0b16ccf9021fc82 => 'Canlı Aktif';

  @override
  String get inlineText_abff5572a370fab7 => 'Sıraya alındı…';

  @override
  String get inlineText_b666d8596482e260 => 'Xray, seçilen IPv4/IPv6 aralıklarını ve paketteki İran alan adı listesini doğrudan yönlendirir. Kuralları değiştirdikten sonra yeniden bağlanın.';

  @override
  String get inlineText_df74ccb45d0e395d => 'Belirli hedefleri Doğrudan, Zorla VPN veya Blok yoluyla yönlendirin.';

  @override
  String get inlineText_1509f561f2416598 => 'Kaydet';

  @override
  String get inlineText_7122ed800123d8e7 => 'Erişim Noktasını Zorla VPN DNS';

  @override
  String get inlineText_6b97c41651da98ce => 'Sistem donanımından otomatik olarak alın';

  @override
  String get inlineText_6f98676a0a7b4953 => 'Özel bağlantı hizmeti';

  @override
  String get inlineText_0fb48c86db0c3f8f => 'VPN';

  @override
  String get inlineText_2427a4a9d7993571 => 'Konuşmacı Günlükleri';

  @override
  String get inlineText_da223b83cdddd9db => 'Hotspot Doctor\'ı çalıştırın';

  @override
  String get inlineText_a899ea0cfb536e60 => 'Oturum belirteçlerini yenileyin veya hesabı değiştirin';

  @override
  String get inlineText_70e3135873ca12f3 => 'Sunucuları yüklemek için giriş yapın';

  @override
  String get inlineText_98e33b0f3104fcf1 => 'Uygulamalar';

  @override
  String get inlineText_c6c2daab1f7d2fe5 => 'Canlı Gerçek Zamanlı Hız';

  @override
  String get inlineText_81e9f4e64a840785 => 'Bunu açmak için en az bir uygulama ekleyin.';

  @override
  String get inlineText_942087cc2d41e013 => 'Yeniden dene';

  @override
  String get inlineText_3fb9aa9bdbb56bb6 => 'Oluştur Yeni liste oluştur';

  @override
  String get inlineText_47e52e5e678a2248 => 'Günlükler panoya kopyalandı (gizli bilgiler düzeltildi).';

  @override
  String get inlineText_cf406ea597d7a11b => 'Tanılama Terminal Çıkışı';

  @override
  String get inlineText_5c8925f30317c4ae => 'IPv6\'i Engelle (Sızıntı Koruması)';

  @override
  String get inlineText_d69fa3897fde1fd7 => 'El sıkışmalar için gerekli hizmet kullanıcı adı ve şifresi';

  @override
  String get inlineText_f98a2522000fbae8 => '200 GB';

  @override
  String get inlineText_30dc86f4e57e4278 => 'Ayarlara uygula';

  @override
  String get inlineText_14eee0b522b0a07f => 'VPN beklenmedik bir şekilde düştüğünde tüm internet sızıntılarını engelleyin';

  @override
  String get inlineText_b813ec3c634e571c => 'Seçilen uygulamaları veya ağ alt ağlarını VPN dışına yönlendirin.';

  @override
  String get inlineText_d21cca3751709e6f => 'Donanım destekli şifreleme: Kimlik bilgileri platform kasasında şifrelenir.';

  @override
  String get inlineText_ff4fcf35e586d0ca => 'Uç Nokta Adayları';

  @override
  String get inlineText_85455433f68a0eea => 'Rota Açıklama';

  @override
  String get inlineText_e6e283499c38fe99 => 'Tümünü test et';

  @override
  String get inlineText_df8bb62c5262aace => 'Klasörü aç';

  @override
  String get inlineText_ca4ce07eeab21f24 => 'Kişisel abonelikler';

  @override
  String get inlineText_ccccab7c5d91fcc1 => 'Release Highlights';

  @override
  String get inlineText_fbfd8ce759281a7c => 'Yeniden giriş yap';

  @override
  String get inlineText_48a39c950b733f9d => 'Hotspot Yönlendirmesini Onarın';

  @override
  String get inlineText_1f914c4386c0676e => 'BAĞLI';

  @override
  String get inlineText_fd67fb8b214d0251 => 'Harmoney Update Available';

  @override
  String get inlineText_5e0104e1d0dd6cc2 => 'Hız Testini Başlat';

  @override
  String get inlineText_9225ef77a358de37 => 'Her Zaman Açık ve Kilitli kapak Firefox, WireGuard, IKEv2 ve OpenVPN. DNS ve IPv6 politikaları her etkin tünel profili tarafından uygulanır.';

  @override
  String get inlineText_04b476ffe80f996f => 'Uygulama başına bypass\'ı etkinleştir';

  @override
  String get inlineText_e0b8edec85fbec56 => 'Sunucu yapılandırması (varsayılan kaynak kodu - yalnızca Hata Ayıklama modunda)';

  @override
  String get inlineText_a47e46554344d955 => 'metin dosyasına kaydedin (parola açık metin olarak saklanır)';

  @override
  String get inlineText_23be2e66d9c671b4 => 'Uygulama bazında bypass\'ı yapılandırmak için yüklü uygulamaları yükleyin.';

  @override
  String get inlineText_60cc8000034bbcc6 => 'Değerleri girin ve manuel olarak oluşturun';

  @override
  String get inlineText_14ea6d8e1758ce8f => 'Giriş yapın Harmoney Pro';

  @override
  String get inlineText_b764cdc0eab71374 => 'Bilinmiyor';

  @override
  String get inlineText_55b98eedd56ac65c => 'Daha fazla protokol ve bağlantı seçeneği';

  @override
  String get inlineText_aa669b285cc133bf => 'Cisco';

  @override
  String get inlineText_5e414ee0c5da2dde => 'Tümüne ping at';

  @override
  String get inlineText_e281f68dc29144b2 => 'Bir HTTP veya HTTPS abonelik URL\'si ekleyin. Bağlantılar bu cihazda güvenli bir şekilde saklanır.';

  @override
  String get inlineText_90f46423c0074765 => 'Oturum İndirme:';

  @override
  String get inlineText_36230e6a755f25c0 => 'Seçilen uygulamalar doğrudan fiziksel ağı kullanır. Diğer uygulamalar VPN\'i kullanmaya devam eder.';

  @override
  String get inlineText_e0166a69e70a0063 => 'Harmoney için etkinleştirildi';

  @override
  String get inlineText_68eda25757c8e549 => 'Kayıtlı abonelikler';

  @override
  String get inlineText_639a40e82b9a96f0 => 'Bağlantı';

  @override
  String get inlineText_2a5c4cf3cff579c9 => 'VPN tünelini atlayıp doğrudan internete bağlanacak uygulamaları seçin.';

  @override
  String get inlineText_229b05d20a6d2706 => 'Firefox VPN Hesabı';

  @override
  String get inlineText_e1f42d830cee8336 => 'Bağlantı hizmeti';

  @override
  String get inlineText_69cd3590300a68c6 => 'Durumu kontrol et';

  @override
  String get inlineText_79f4939f31f74600 => 'Android Koruması';

  @override
  String get inlineText_e9f61c5ca23f266f => 'Tüm sağlayıcılardan ve protokollerden canlı bağlantı olayları';

  @override
  String get inlineText_a0610c3d3b91cb4f => 'Harmoney Smart';

  @override
  String get inlineText_c0671aa2f2dd814a => 'Download & Update';

  @override
  String get inlineText_1a938f00d128e40c => 'Canlı Hız ve Trafik';

  @override
  String get inlineText_74ca300a6cadb68a => 'Etkin Nokta IPv6 Politikası';

  @override
  String get inlineText_c2ed1ff176791192 => 'Yönlendirme Politikası:';

  @override
  String get inlineText_b8b960fef99adfb1 => 'Harmoney Pro\'da Oturum Açmanız Gerekiyor';

  @override
  String get inlineText_a23e527773f02a67 => 'Harmoney';

  @override
  String get inlineText_2067e249c2b1e5de => 'Kota Aşıldı Eylem:';

  @override
  String get inlineText_3b61e4e936523550 => 'Açıkla';

  @override
  String get inlineText_bd8256cb9d1b917f => 'Kurallar etkin VPN rotasına uygulanır. UDP aktarımı henüz tamamlanmadı; UDP gerektiren uygulamalar VPN dışında tam olarak çalışmayabilir.';

  @override
  String get inlineText_664479f12348ca20 => 'Çıkartmayı başlat';

  @override
  String get inlineText_2fd1a96a8b9a93c0 => 'Surfshark Hizmet Hesabı';

  @override
  String get inlineText_37d1bd40cc9b7ba7 => 'Seçilen uygulamaları doğrudan fiziksel ağ bağdaştırıcınız üzerinden göndermek için Windows yerel işlem başına yönlendirmeyi kullanır. Uyumlu bir Windows yapısı ve Harmoney VPN hizmeti gerektirir.';

  @override
  String get inlineText_e2419bb6585fdf13 => 'Ülke hedefleri VPN\'i doğrudan ISP aracılığıyla atlar; diğer trafik VPN\'in içinde kalır.';

  @override
  String get inlineText_566bd7ec6c74731b => 'Sistemde aktif erişim noktası arayüzü algılanmadı.';

  @override
  String get inlineText_1d653fc4503ec979 => 'The update will download and install directly inside Harmoney.';

  @override
  String get inlineText_9e4a7faff61f59aa => 'Donanım Profili: Dell Latitude 7210 ve Intel / Hücresel LTE';

  @override
  String get inlineText_515c0e6425c1c144 => 'Henüz CIDR kuralı yok.';

  @override
  String get inlineText_60c5a84642b61c53 => 'Android VPN ayarlarında Kilitlemeyi etkinleştirin';

  @override
  String get inlineText_cb222670e743b957 => 'Şifre';

  @override
  String get inlineText_d1ad5bbe561caba5 => 'Hedefi Engelle';

  @override
  String get inlineText_54b8e0c0c268c154 => 'Raporu Kopyala';

  @override
  String get inlineText_7539a050c6489953 => 'Harmoney Pro indirme bağlantısı henüz kullanılamıyor.';

  @override
  String get inlineText_4759498ac2a719c6 => 'Oluştur';

  @override
  String get inlineText_089899b425d4bcda => 'Abonelik ekle';

  @override
  String get inlineText_838c8e30c9aeac8a => 'Misafir Erişim Noktası';

  @override
  String get inlineText_475e433587200d99 => 'VPN düştüğünde yurt içi hizmetleri ve bankacılığı erişilebilir tutun';

  @override
  String get inlineText_0b4666b1dcc9f6f9 => 'Bölünmüş Tünel Oluşturmayı Etkinleştir';

  @override
  String get inlineText_cb2b6a572a8588d8 => 'Bağlantı kesiliyor…';

  @override
  String get inlineText_fb94fc702eb62ab7 => 'Harmoney Pro\'yu indir';

  @override
  String get inlineText_ad7b66a913a46286 => 'BAĞLANTI KESİLİYOR';

  @override
  String get inlineText_74a883a037bc227f => 'Ayarlar';

  @override
  String get inlineText_6c2a96757bb1ab31 => 'API Ayarları';

  @override
  String get inlineText_a63b3bb0ad3689a0 => 'Önceki VPN işlemi zaman aşımına uğradı. Tekrar deneyebilirsiniz.';

  @override
  String get inlineText_b11e1aa7421b52e2 => 'Rota testi';

  @override
  String get inlineText_73b6e48a1b552d11 => 'Later';

  @override
  String get inlineText_c1c1009d3f37ec05 => 'Update';

  @override
  String get inlineText_fa488105cb65db88 => 'Güvenlik oturumunun süresi doldu; sunucuları kullanmak için lütfen tekrar oturum açın.';

  @override
  String get inlineText_4bd0e4ba0e817d11 => 'Sınırsız (Kapalı)';

  @override
  String get inlineText_690dbe9dc0993c42 => 'Son';

  @override
  String get inlineText_005ef7725a64c7ed => 'New Version Available';

  @override
  String get inlineText_92723a5ff9689c3d => 'Xray, WARP ve MASQUE konfigürasyonlarından rotalar. Bağlantı, trafik doğrulamasından sonra gösterilir.';

  @override
  String get inlineText_c5842271209f9ff7 => 'Protokol kapsamı olmadan bağlantıları engelleyin';

  @override
  String get inlineText_1fc9a387654d410f => 'Tümünü seç';

  @override
  String get inlineText_b0e17c2810653b13 => 'Install Now';

  @override
  String get inlineText_5aa9ef74c967df76 => 'Özel Konum Listeleri';

  @override
  String get inlineText_ad208643ab98407d => 'Erişim noktası paylaşım tercihi kaydedildi.';

  @override
  String get inlineText_5e1133591cfeb5b0 => 'Yalnızca etkin nokta istemcileri';

  @override
  String get inlineText_d636391ee4236395 => 'Henüz eşleşen etkinlik yok. Günlükleri toplamak için bir VPN bağlantısı başlatın.';

  @override
  String get inlineText_ebbe7ab0b58e10be => 'Abonelik QR\'sini tara';

  @override
  String get inlineText_092283a13b34e9ed => 'Sunucuları göster';

  @override
  String get inlineText_e548577f0fd46659 => 'Firefox Hesabı kimlik bilgileri, yerel Android motoru tarafından doğrudan Mozilla\'ya gönderilir. Şifrelenmiş tokenler hiçbir zaman Flutter depolama alanına girmez.';

  @override
  String get inlineText_a836bff92bbc5af0 => 'Hesaba yeniden giriş yapın';

  @override
  String get inlineText_50688e3917acdfec => 'Seçilen sunucu listesini JSON ve TXT dosyaları olarak dışa aktarın.';

  @override
  String get inlineText_9b13e877e4aa90a7 => 'Giriş Yapıldı';

  @override
  String get inlineText_854d3eab6d8d5d33 => 'Oturum açma ve sunucuları yükleme';

  @override
  String get inlineText_c0d31ce834b82a7e => 'Favori sunucu yok.';

  @override
  String get inlineText_4511036a54304f80 => 'Update Download Complete';

  @override
  String get inlineText_76b23f49c19a08d8 => 'Tüm cihaz DNS sorgularını Surfshark DNS\'e yönlendirin.';

  @override
  String get inlineText_5a23444828db654a => 'Üstesinden gelmek';

  @override
  String get inlineText_5fedacfb015245b7 => 'Canlı Bağlantı Günlükleri (Akış)';

  @override
  String get inlineText_7446eabf9cf13622 => 'IPv6 sızıntı koruması';

  @override
  String get inlineText_2de8796023cbb4c7 => 'Limit Ayarı Yok';

  @override
  String get inlineText_7a7832e87a88a9c7 => 'WFP, kuralları IKEv2, WireGuard, OpenVPN ve Xray\'den bağımsız olarak uygular. UDP geçişi henüz tamamlanmadığından UDP gerektiren uygulamalar tamamen atlanmayacak.';

  @override
  String get inlineText_a0e1a519f04a9b3e => 'BAĞLANIYOR';

  @override
  String get inlineText_289afa804e34a45f => 'Karantina sırasında İran trafiğine izin ver';

  @override
  String get inlineText_ce13fbfce966190e => 'Henüz abonelik eklenmedi.';

  @override
  String get inlineText_893e490d64407b8e => 'Kota bilgisi mevcut değil';

  @override
  String get inlineText_9b89006aec802e94 => 'Canlı Günlükler';

  @override
  String get inlineText_630c2f1c0ee1b8d7 => 'AKTİF';

  @override
  String get inlineText_92340695899bd2d8 => 'Aktif';

  @override
  String get inlineText_203229774cceb5f3 => 'Hesabı Yönet';

  @override
  String get inlineText_bf6ccf81398eed34 => 'İlke Ekle';

  @override
  String get inlineText_a9884f2d7e028e02 => 'İçe aktarılan profil bulunamadı.\\nSurfshark Manuel Kurulum\'dan bir ZIP arşivini içe aktarın.';

  @override
  String get inlineText_0c16e4802957bf2a => 'Update Interrupted';

  @override
  String get inlineText_94f105a3d269670f => 'Bir konum seçin veya en hızlı sunucuyu kullanın';

  @override
  String get inlineText_472590ae974d4c1f => 'Sağlayıcı';

  @override
  String get inlineText_5541de9515522b98 => 'BAĞLANTI KESİLDİ';

  @override
  String get inlineText_0e223795fafb578e => 'Koruma ayarları Android VpnService tarafından uygulanır ve yeniden bağlandıktan sonra etkili olur.';

  @override
  String get inlineText_bfd402b2f6f38125 => 'Oturum aç';

  @override
  String get inlineText_970c6a41454fa6ee => 'Genel Tünel Sağlığını Yenile';

  @override
  String get inlineText_f4c3265a274f6fa8 => 'IPv6\'i desteklenen tünellerden geçirin; uygulamak için yeniden bağlanın';

  @override
  String get inlineText_ecf1d7c868ee46fc => 'Mbps';

  @override
  String get inlineText_f9f60b474c0c751b => 'Konuk Erişim Noktasını Başlat';

  @override
  String get inlineText_a840a9de3127ef53 => 'FireTunnel, Firefox Hesaplarıyla kimlik doğrulaması yapar. Kimlik bilgileri yalnızca kökten yalıtılmış yerel yardımcıya gönderilir; tokenlar hiçbir zaman Flutter depolama alanına girmez.';

  @override
  String get inlineText_dcbf414d58c417be => 'Acil Durdurma';

  @override
  String get inlineText_4f5845ea70794fc8 => 'Harmoney Sansür Karşıtı Çekirdek';

  @override
  String get inlineText_0234c7f3ac8b5b71 => 'Uygulama atlama özelliğini etkinleştir';

  @override
  String get inlineText_24b8d9733417f7f2 => 'Güvenli tünel kuruluyor…';

  @override
  String get inlineText_ec963ffc911b8401 => 'Kontrol ediliyor…';

  @override
  String get inlineText_c46c2996102a4b2c => 'Şifreli tünel sıfır paket sızıntısıyla doğrulandı.';

  @override
  String get inlineText_c0bf75bd78bf9572 => 'Değiştirmek';

  @override
  String get inlineText_bcc0bcc9140b0c97 => 'Oturum aç';

  @override
  String get inlineText_e7977ed18b1df209 => 'Uygulama başına atlama';

  @override
  String get inlineText_0e91610117029a62 => 'Yenile';

  @override
  String get inlineText_6defafa2caa65304 => 'Yapılandır';

  @override
  String get inlineText_651f94aafffed603 => 'Bağlantı kesme isteği hâlâ işleniyor…';

  @override
  String get inlineText_8b9d3de8ae00c89c => 'Oturum açılıyor…';

  @override
  String get inlineText_58b2c361864f4c09 => 'Her zaman açık VPN';

  @override
  String get inlineText_8aa2064e8f385ad3 => 'Hizmet Kimlik Bilgileri ve Anahtarları';

  @override
  String get inlineText_7bcc95e0b5bd34c6 => 'Uygulama başına VPN bypass\'ı';

  @override
  String get inlineText_be6ee118f6ce86a8 => 'Downloading Update...';

  @override
  String get inlineText_67865eaee364dcbe => 'Tutarlı filtreleme için HTTPS trafiğini TCP/TLS üzerinden zorlayın.';

  @override
  String get inlineText_a52ace420f2175d0 => 'Tüm';

  @override
  String get inlineText_2eb0c5a3ce65868c => 'Canlı bant genişliği, veri muhasebesi ve kota';

  @override
  String get inlineText_54386d5a6b84b6e8 => 'Pil Optimizasyonu Aktif (Doze Modu)';

  @override
  String get inlineText_d0e13ceb47c44a7f => 'Akıllı yönlendirme ve kişisel abonelikler';

  @override
  String get inlineText_1924fc22b6e86d49 => 'Aktif Surfshark Protokolü';

  @override
  String get inlineText_1eecb5c3f3e93223 => '\'yi atlayın Android CIDR rotalarını uygulamak için VPN\'i yeniden bağlayın.';

  @override
  String get inlineText_0ef1d485c68962e3 => 'Varsayılan sunucu';

  @override
  String get inlineText_1e77e9d04f19d6d9 => 'Ana Bilgisayar ve Erişim Noktası istemcileri';

  @override
  String get inlineText_f5af9ab211b447cd => 'Hız raporu panoya kopyalandı!';

  @override
  String get inlineText_edb18cd663b5e4de => 'Blok QUIC (UDP 443)';

  @override
  String get inlineText_ea32ef00138d4d85 => 'Bağlı cihazları, bant genişliği kotalarını, konuk Wi-Fi\'i ve yönlendirme politikalarını yönetin.';

  @override
  String get inlineText_46ff63176dfa61e2 => 'Zorunlu VPN';

  @override
  String get inlineText_f6f75ce9317a16db => 'Kotayı Zorunlu Kıl';

  @override
  String get inlineText_72fe71cb37d209d2 => 'Durumu Yenile';

  @override
  String get inlineText_56b598dee4ddc136 => 'EN HIZLI ⚡';

  @override
  String get inlineText_19766ed6ccb2f4a3 => 'İptal';

  @override
  String get inlineText_7a1f2a83aca9a081 => 'Favoriler';

  @override
  String get inlineText_876662d1d94ad13b => 'Canlı Doğrulama';

  @override
  String get inlineText_bf26c2ac087da6ff => 'Baypas';

  @override
  String get inlineText_dfe40efe921fe88e => 'Güncelleniyor…';

  @override
  String get inlineText_247ea0cd6733f4fc => 'Acil Durdurma yürütüldü: İşlemler sonlandırıldı ve fiziksel ağdaki sıkışma çözüldü.';

  @override
  String get inlineText_7207233f2b0688ac => 'Hızlı bağlantı';

  @override
  String get inlineText_3c4846f1083e22ec => 'Bölünmüş Tünel Açma';

  @override
  String get inlineText_ec93679622950c2c => 'Varsayılan depolama konumu:';

  @override
  String get inlineText_a76e13b9839270eb => 'Eski haline getirmek';

  @override
  String get inlineText_a4738b604a205c2e => 'Check Updates';

  @override
  String get inlineText_c4b662bd95db40f1 => 'Saklanan kimlik bilgilerini bu cihazdan temizle';

  @override
  String get inlineText_adde42042c5c3caa => 'Cihaz Bağlantısını Duraklat';

  @override
  String get inlineText_200bc33c838b6604 => 'Varsayılan sunucu kimliği';

  @override
  String get inlineText_ea61bc15688d1e48 => 'Kopyalandı!';

  @override
  String get inlineText_d3ee5446e626ae8f => 'Ağ Alt Ağları (CIDRs)';

  @override
  String get inlineText_1640ef1a61f9a5ee => 'Ülke atlama DAT kuralları güncellendi. Uygulamak için VPN\'i yeniden bağlayın.';

  @override
  String get inlineText_d403c686f6a10480 => 'Bağlanıyor';

  @override
  String get inlineText_351d257b580bc419 => 'İstediğiniz VPN ağ sağlayıcısını seçin';

  @override
  String get inlineText_1b4154057e37a0ff => 'Harmoney Pro\'da Oturum Açın';

  @override
  String get inlineText_ae4e9b1ef2aa3860 => 'Surfshark Protokolünü Seçin';

  @override
  String get inlineText_83b12c2216efb4fd => 'Temizlemek';

  @override
  String get inlineText_269f0582347dbdf6 => 'Önerilen Hızlı Rotalar';

  @override
  String get inlineText_9918aaf803c54fcf => 'QR resmini seçin';

  @override
  String get inlineText_307e253c39bae652 => 'Bağlantı Testi';

  @override
  String get inlineText_337db382095ce88d => 'Seçilen VPN aracılığıyla cihaz DNS sorgularını yönlendirin.';

  @override
  String get inlineText_5bb6d1b367fc7674 => 'WireGuard';

  @override
  String get inlineText_e8696f00501ad45a => 'İçe aktarılmış profil bulunamadı.\nSurfshark Manuel Kurulum\'dan bir ZIP arşivi içe aktarın.';

  @override
  String get inlineText_b0230c537ca88c85 => 'Kullanıcı Uygulamaları';

  @override
  String get inlineText_e9d51941d0c1f37b => 'VPN Erişim Noktası Paylaşımı (Windows ICS)';

  @override
  String get inlineText_6bcc8512de553613 => 'Tüm Sunucuları Göster';

  @override
  String get inlineText_9d4be9539f27c657 => 'Henüz özel liste oluşturulmadı.';

  @override
  String get inlineText_782ec78be81185c6 => 'FireTunnel Belirteci / Şifre';

  @override
  String get inlineText_8a76134e54b9cfac => 'ANAHTAR GEREKLİ';

  @override
  String get inlineText_75081b593d15cf6e => 'Engelli';

  @override
  String get inlineText_2e5f79bb94a8c40b => 'Checking...';

  @override
  String get inlineText_471354282a521dd1 => 'Yeni Özel Liste';

  @override
  String get inlineText_c7a43600b2a6507c => 'Oturum aç / Hesap';

  @override
  String get inlineText_a919cfce15c49685 => 'Kilitleme modu (Kill Switch)';

  @override
  String get inlineText_dd9e7664f013c1e5 => 'Ayrıcalıklı platform anahtar deposunda şifrelenen kimlik bilgileri';

  @override
  String get inlineText_f50e254cf57f39fd => '128 kbit/s\'ye kısın';

  @override
  String get inlineText_4e1af7c74096cf0a => 'İşlem başarısız oldu';

  @override
  String get inlineText_43e3ece73ff8f4eb => 'remaining';

  @override
  String get inlineText_e94356112ce4c59c => 'Erişim Noktası ve Cihazlar';

  @override
  String get inlineText_313cbecb4dd35728 => 'Kapat';

  @override
  String get inlineText_d6eafe8235910042 => 'İndirmek';

  @override
  String get inlineText_06bacdb5d18b0261 => 'İnterneti engelle';

  @override
  String get inlineText_8200a83deae2141b => 'CIDR kuralı ekle';

  @override
  String get inlineText_a429cd15905e58a5 => 'Kota Ayarla';

  @override
  String get inlineText_57c95945cb8fe988 => 'VPN hizmeti kimlik bilgileri güvenli bir şekilde kaydedildi.';

  @override
  String get inlineText_4ff946afb073da91 => 'VPN Profillerini Yönet';

  @override
  String get inlineText_9bf1e054ed4cbacb => 'Komut satırından daha kolay bağlantı için kullanıcı adını ve parolayı';

  @override
  String get inlineText_6cb535909a7f3875 => 'Tam Denetimi Çalıştır';

  @override
  String get inlineText_8fcbf6bb3bf0b5a0 => 'Gecikmeye göre sırala';

  @override
  String get inlineText_45ee3e003650a75f => 'Yönlendirme Politikası Kuralı Ekle';

  @override
  String get inlineText_04b93833872cc896 => 'Bağlantı kesme isteği gönderildi…';

  @override
  String get inlineText_ad3d9699142e5339 => 'Güvenli bir şekilde kaydedin';

  @override
  String get inlineText_c63e407525237f8d => 'VPN Hata Ayıklama Günlükleri';

  @override
  String get inlineText_530692d19626e11a => 'Xray, seçilen IPv4/IPv6 aralıklarını ve paketlenmiş İran alan adı listesini doğrudan yönlendirir. Windows IKEv2 rota enjeksiyonu yalnızca IPv4 olarak kalır. Kuralları değiştirdikten sonra yeniden bağlanın.';

  @override
  String get inlineText_7c147e122ed7eeac => 'OpenVPN';

  @override
  String get inlineText_e17b6227325e1a8d => 'Akıllı Hizmet Uygunluğu';

  @override
  String get inlineText_73bfa58718abc908 => 'Tünel yolu denetimleri, sızıntı testleri, gecikme araştırmaları ve çalışma zamanı telemetrisi';

  @override
  String get inlineText_659e50811965fe84 => 'Aylık Ödenek';

  @override
  String get inlineText_6a4c3a4483b04488 => 'Ping';

  @override
  String get inlineText_11a6767d5674c7e4 => 'Bitti';

  @override
  String get inlineText_acfc5be785a9bb3d => 'Bağlantıyı kes';

  @override
  String get inlineText_c3812fc4acb861d5 => 'Kaldır';

  @override
  String get inlineText_fe4f5f9fd7be7d92 => 'İstemci Yalıtımı';

  @override
  String get inlineText_865e89de78d94c74 => 'Yüklemek';

  @override
  String get inlineText_0004bf6db9f12d54 => 'Ülke Kurallarını Güncelleyin';

  @override
  String get inlineText_3e695daee969126c => 'Package installer launched. Tap below if you need to relaunch.';

  @override
  String get inlineText_a8b3ef62feba073f => 'Hiçbir sunucu bulunamadı.';

  @override
  String get inlineText_9ef0f877893218f3 => 'Firefox VPN Belirteci ve Kimlik Doğrulaması';

  @override
  String get inlineText_23759997b3c59884 => 'BİLİNMİYOR';

  @override
  String get inlineText_e3b78e09863c99ac => 'Etkin Nokta Doktoru ve Teşhis';

  @override
  String get inlineText_48845bff334a50a5 => 'Dismiss';

  @override
  String get inlineText_54a0e8c17ebb21a1 => 'Hata';

  @override
  String get inlineText_c8fd5b73d111ee1d => ', Harmoney tarafından';

  @override
  String get inlineText_44e1911932d93644 => 'Harmoney Pro Hizmeti';

  @override
  String get inlineText_f6be68de3c8d5e7d => 'Aylık Veri Kotası';

  @override
  String get inlineText_51452219a8542052 => 'Yapılandırılmış uç nokta adayı yok.';

  @override
  String get inlineText_f493cd9c7ae396ec => 'Firefox tünelini etkinleştirmek ve veri kotasını görüntülemek için oturum açın.';

  @override
  String get inlineText_8e1b786c7913210c => 'Kotayı Kaydet';

  @override
  String get inlineText_efb52e7172b77731 => 'Tema';

  @override
  String get inlineText_2c2648394a4fe357 => 'Bölünmüş tünel ekle CIDR';

  @override
  String get inlineText_ff6d5def69d21f32 => 'Bağlı sıcak nokta istemcilerinin doğrudan iletişim kurmasını önleyin.';

  @override
  String get inlineText_532eaabd9574880d => 'Testi';

  @override
  String get inlineText_02a2c8aa276c0c36 => 'Tünel tarafından yönetilen DNS; uygulamak için yeniden bağlanın';

  @override
  String get inlineText_abaf4ed786bb9340 => 'VPN';

  @override
  String get inlineText_49a2fc4df1b8bad5 => 'Hafif Firefox VPN tüneli';

  @override
  String get inlineText_2faba03e2b8726a9 => 'Son Hız Karşılaştırması:';

  @override
  String get inlineText_5bb4dc6f47d4c040 => 'BAĞLAMAK';

  @override
  String get inlineText_9d4ad0b61b2359e9 => 'ZIP Arşivini İçe Aktarın';

  @override
  String get inlineText_243a20f9ba6c2892 => 'Bu sınıra ulaştığınızda görsel uyarılar alacaksınız.';

  @override
  String get inlineText_d3ae19164d4f0f44 => 'Teşhis ve Sağlık';

  @override
  String get inlineText_3dd7fcefed0e482c => 'Erişim Noktası Etkin Değil';

  @override
  String get inlineAttribute_a4282e4b2298b90b => '\'den';

  @override
  String get inlineAttribute_1a765360a12ba19c => 'Ülkeleri ara…';

  @override
  String get inlineAttribute_74c8361a4a1ca4c4 => 'Rota eylemi';

  @override
  String get inlineAttribute_be6ee118f6ce86a8 => 'Downloading Update...';

  @override
  String get inlineAttribute_440488e7af1a1602 => 'Etki Alanı, IPv4 veya CIDR';

  @override
  String get inlineAttribute_1d653fc4503ec979 => 'The update will download and install directly inside Harmoney.';

  @override
  String get inlineAttribute_372167bb30249862 => 'Veri Kotası (MB, 0 = sınırsız)';

  @override
  String get inlineAttribute_4b329f46e3e4aa50 => 'kaldı';

  @override
  String get inlineAttribute_8d634757de9d475f => '✓ Doğrulandı: Tüm kontroller başarılı oldu (XFRM, tablo 220, HTTPS izleme)';

  @override
  String get inlineAttribute_b9893538a61f89ed => 'Aboneliğin kullanıcı adı';

  @override
  String get inlineAttribute_2c80752638d7bd54 => 'yapıştır';

  @override
  String get inlineAttribute_df3b5afaf2778138 => 'Etki Alanı veya IP';

  @override
  String get inlineAttribute_1803685bb41d1d8d => 'Abonelik URL\'si';

  @override
  String get inlineAttribute_09231cb8338a0158 => 'Hedef Etki Alanı veya CIDR (ör. 1.1.1.1/32)';

  @override
  String get inlineAttribute_474276a023bed5d8 => 'Tercih edilen ad (isteğe bağlı)';

  @override
  String get inlineAttribute_69612b885a0aff86 => 'Popüler Sunucu';

  @override
  String get inlineAttribute_e7cf3ef4f17c3999 => 'Şifre';

  @override
  String get inlineAttribute_f3380f7b44bd70af => 'Yapıştır';

  @override
  String get inlineAttribute_ad0eae0c2cd935dc => 'armoney';

  @override
  String get inlineAttribute_3c128b5436b6d704 => 'Tümünü yenile';

  @override
  String get inlineAttribute_969ccbd3cf6300ec => 'E-posta';

  @override
  String get inlineAttribute_1b37568c4311efeb => 'Uygulama adı veya pakete göre ara';

  @override
  String get inlineAttribute_4524cd31be7128c2 => 'ör. 192.168.1.0/24 veya 10.0.0.1/32';

  @override
  String get inlineAttribute_6077b2acb8754468 => 'Uç noktayı etkinleştirin';

  @override
  String get inlineAttribute_b84364651ab4f422 => 'CIDR veya IP';

  @override
  String get inlineAttribute_73b6e48a1b552d11 => 'Later';

  @override
  String get inlineAttribute_be420e2629f2ebfa => 'E-posta doğrulama kodu';

  @override
  String get inlineAttribute_c1c1009d3f37ec05 => 'Update';

  @override
  String get inlineAttribute_b29904a25f1802a7 => 'Süre (Dakika, 5-1440)';

  @override
  String get inlineAttribute_a4738b604a205c2e => 'Check Updates';

  @override
  String get inlineAttribute_428ffb88a815b9be => 'Görünümü temizle';

  @override
  String get inlineAttribute_6016fb957fe261cc => 'Tümünü güncelle';

  @override
  String get inlineAttribute_005ef7725a64c7ed => 'New Version Available';

  @override
  String get inlineAttribute_a1ab6eca52db1b3b => 'test sunucusundan';

  @override
  String get inlineAttribute_4504b2c82bef3d20 => 'Günlükleri kopyala';

  @override
  String get inlineAttribute_356c851e4ec59a3d => 'Cihazı yapılandırın';

  @override
  String get inlineAttribute_c2ef8dd2545d2b04 => 'Liste adı (ör. Avrupa Hızlı)';

  @override
  String get inlineAttribute_f69c34c2fc4b9667 => 'Favori sunucu';

  @override
  String get inlineAttribute_00ea6b3b42dfb4b5 => 'Donanım Kimliğini Kişiselleştirin ve Manuel Olarak Oluşturun';

  @override
  String get inlineAttribute_b073f6c68ef87211 => 'Kapsam';

  @override
  String get inlineAttribute_59ca629220a63ede => 'Sil';

  @override
  String get inlineAttribute_47311af432a79c40 => 'Profili sil';

  @override
  String get inlineAttribute_80884fb559e05bd9 => 'Açıklamak için';

  @override
  String get inlineAttribute_b0e17c2810653b13 => 'Install Now';

  @override
  String get inlineAttribute_6769ff871d28e2ce => 'Çıkışı kapat';

  @override
  String get inlineAttribute_01e8ee2044c91ec5 => '•••••••••••••••••';

  @override
  String get inlineAttribute_cdf0cf9ecdfecba8 => 'Özel Listeler';

  @override
  String get inlineAttribute_05eccbc907509b4b => 'Hız sınırı (kbit/s, 0 = sınırsız)';

  @override
  String get inlineAttribute_d4e54f76384bf545 => '\'ye devam et Probu yeniden dene';

  @override
  String get inlineAttribute_d3a8a299660b14d0 => 'Günlükleri temizle';

  @override
  String get inlineAttribute_7a3517625d7f32a6 => 'Çıkışı Kopyala';

  @override
  String get inlineAttribute_96f681e1e0e80f53 => 'Sağlayıcıya, protokole, duruma veya hataya göre filtreleyin';

  @override
  String get inlineAttribute_4511036a54304f80 => 'Update Download Complete';

  @override
  String get inlineAttribute_2e5f79bb94a8c40b => 'Checking...';

  @override
  String get inlineAttribute_842d8e425ecb5b64 => ' / ';

  @override
  String get inlineAttribute_ce21ed09a64c529b => 'Kopyalanan abonelik bağlantısı algılandı.';

  @override
  String get inlineAttribute_1e5a5a18ae04113a => 'Hızlı Menü';

  @override
  String get inlineAttribute_c611981fab983bc6 => 'Politika';

  @override
  String get inlineAttribute_43e3ece73ff8f4eb => 'kaldı';

  @override
  String get inlineAttribute_a624a1e41ffdc6d6 => ' / ';

  @override
  String get inlineAttribute_fb156130b17c4be3 => 'Hesap seçenekleri';

  @override
  String get inlineAttribute_0e08705e56eb56d8 => 'Görünür günlükleri kopyala';

  @override
  String get inlineAttribute_c16db1ad02461665 => 'Hata Ayıklama Günlükleri';

  @override
  String get inlineAttribute_f16edb7443f05225 => 'Konuk Durumunu Yenile';

  @override
  String get inlineAttribute_ca4ce07eeab21f24 => 'Kişisel abonelikler';

  @override
  String get inlineAttribute_ccccab7c5d91fcc1 => 'Release Highlights';

  @override
  String get inlineAttribute_0b33748029674d12 => 'Ülkeyi, şehri, IP adresini ara...';

  @override
  String get inlineAttribute_fd67fb8b214d0251 => 'Harmoney Update Available';

  @override
  String get inlineAttribute_0c16e4802957bf2a => 'Update Interrupted';

  @override
  String get inlineAttribute_a291d1863aeedb00 => 'Yinelenen bağlantı bulundu.';

  @override
  String get inlineAttribute_44bd7ae60f478fae => 'H';

  @override
  String get inlineAttribute_c97f606c82316bc1 => 'Günlük dosyasını dışa aktarın';

  @override
  String get inlineAttribute_e09b37bcc4f301f4 => 'Ad (isteğe bağlı)';

  @override
  String get inlineAttribute_0ca0dfe5e1ff7a8e => 'Hesap İşlemleri';

  @override
  String get inlineAttribute_c3812fc4acb861d5 => 'Kaldır';

  @override
  String get inlineAttribute_3e695daee969126c => 'Package installer launched. Tap below if you need to relaunch.';

  @override
  String get inlineAttribute_48845bff334a50a5 => 'Dismiss';

  @override
  String get inlineAttribute_9b64398e9f8fef53 => 'Test sunucusu';

  @override
  String get inlineAttribute_ea9d303a5e54fb42 => 'Aşamaya göre filtreleyin (HAZIRLIK, IKE, KİMLİK DOĞRULAMA, DOĞRULANIYOR, BAĞLANTI, BAŞARISIZ) veya anahtar kelimeye göre filtreleyin…';

  @override
  String get inlineAttribute_d640c7421da06661 => '\'yi kaldır';

  @override
  String get inlineAttribute_140669bdb031e927 => 'Abonelik bağlantısı';

  @override
  String get inlineAttribute_16f78a7d6317f102 => 'kullanıcı adı';

  @override
  String get inlineAttribute_e1a0ff7a5353c7fe => 'Konuk SSID';

  @override
  String get inlineAttribute_e098b630f04d6d69 => 'Etki Alanı veya IP\'yi devre dışı bırakın';

  @override
  String get inlineAttribute_0f39d38fb65968d0 => 'Abonelik Şifresi';

  @override
  String get inlineAttribute_858e4ba7a29fd38b => 'Duraklat';

  @override
  String get inlineAttribute_3dea43271fc3f002 => 'Yüklü uygulamaları veya paketleri arayın';

  @override
  String get inlineAttribute_ac8619ca1957889c => 'kişisel abonelikler';

  @override
  String get inlineAttribute_f8a5decc321d9f7a => 'Ülke, şehir, IP ara...';

  @override
  String get inlineAttribute_82ab1760fe92313f => 'Motor bağlantısı günlük akışı olaylarını mı bekliyorsunuz?';

  @override
  String get inlineAttribute_c0671aa2f2dd814a => 'Download & Update';

  @override
  String get inlineTextTemplate_2e5f79bb94a8c40b => 'Checking...';

  @override
  String get inlineTextTemplate_4b5e556c141daca0 => 'Uygulama kuralı güncellenemedi: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_fe5115c86ab563dd => 'QZXVAR0QZX CIDRs';

  @override
  String get inlineTextTemplate_f6fd414931d6a430 => 'Gecikme testi başarısız oldu: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_be6ee118f6ce86a8 => 'Downloading Update...';

  @override
  String get inlineTextTemplate_fe4eac0d19b1f8b2 => 'Dışa aktarma başarısız oldu: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_846aa6f62acf906c => 'Silinemedi: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_1d653fc4503ec979 => 'The update will download and install directly inside Harmoney.';

  @override
  String get inlineTextTemplate_0b59208593d747ad => 'Uygulama eklenemedi: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_bfafae05cba5bb86 => 'Sunucular yüklenemedi: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_1a1e3bf73b281b6d => 'Uygulama atlama ayarları yüklenemedi: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_3c17c68905f8856a => 'Hata: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_e52ff58d5b3af8f0 => 'Ülke Baypas: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_8bc4d9b4f92c60ab => 'Uygulama atlama güncellenemedi: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_8df4368ecb09de86 => 'Sıkışmayı giderme başarısız oldu: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_0d1e9be15aed1231 => 'Bağlı Cihazlar (QZXVAR0QZX)';

  @override
  String get inlineTextTemplate_601fcd78f13053e1 => '↓ QZXVAR0QZX Mbps';

  @override
  String get inlineTextTemplate_972ff659f6e27b76 => 'QZXVAR0QZX\'ten (QZXVAR1QZX) donanım kimliği alındı.';

  @override
  String get inlineTextTemplate_ccccab7c5d91fcc1 => 'Release Highlights';

  @override
  String get inlineTextTemplate_a170e1c90b9a1695 => 'QZXVAR0QZX\'e kaydedildi';

  @override
  String get inlineTextTemplate_7e941c183788df69 => 'Ping: QZXVAR0QZXms · Titreşim: QZXVAR1QZXms · QZXVAR2QZX';

  @override
  String get inlineTextTemplate_fd67fb8b214d0251 => 'Harmoney Update Available';

  @override
  String get inlineTextTemplate_0c16e4802957bf2a => 'Update Interrupted';

  @override
  String get inlineTextTemplate_e100a78e26906915 => 'QZXVAR0QZX kaldı';

  @override
  String get inlineTextTemplate_e24a324bdb714d54 => 'Güncellendi: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_a8f0cc53b0dca9ef => 'Uygulama kaldırılamadı: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_2347df78592d100a => 'QZXVAR0QZX seçilen ülkeler (QZXVAR1QZX CIDRs)';

  @override
  String get inlineTextTemplate_73b6e48a1b552d11 => 'Later';

  @override
  String get inlineTextTemplate_c1c1009d3f37ec05 => 'Update';

  @override
  String get inlineTextTemplate_2b5bf24f64089836 => 'Acil Durdurma hatası: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_a4738b604a205c2e => 'Check Updates';

  @override
  String get inlineTextTemplate_3e695daee969126c => 'Package installer launched. Tap below if you need to relaunch.';

  @override
  String get inlineTextTemplate_005ef7725a64c7ed => 'New Version Available';

  @override
  String get inlineTextTemplate_e416fbfd7a91ed9f => 'QZXVAR0QZX WireGuard ve QZXVAR1QZX OpenVPN profillerini güvenli bir şekilde içe aktarın.';

  @override
  String get inlineTextTemplate_892b097363290e03 => 'Durum: QZXVAR0QZX · Gecikme: QZXVAR1QZX';

  @override
  String get inlineTextTemplate_876c1a21e4aca06e => 'Sürümü: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_48845bff334a50a5 => 'Dismiss';

  @override
  String get inlineTextTemplate_a1868bb4d6de7026 => 'Cihazı Yapılandırma: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_df0ea8d18fa1b297 => 'QZXVAR0QZX\'te desteklenmez';

  @override
  String get inlineTextTemplate_d437f3d2dc2207b4 => 'Otomatik başlatma güncellenemedi: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_8e339613f844cd3f => 'QZXVAR0QZX Mbps (Ping QZXVAR1QZXms)';

  @override
  String get inlineTextTemplate_b0e17c2810653b13 => 'Install Now';

  @override
  String get inlineTextTemplate_251f8b3bcb3ff541 => 'Seçilen Surfshark konumlarıyla eşleşen içe aktarılan QZXVAR0QZX profili yok.';

  @override
  String get inlineTextTemplate_b027e90663d6b737 => 'QZXVAR0QZX konumları';

  @override
  String get inlineTextTemplate_732cc46253cae40a => 'QZXVAR0QZXms';

  @override
  String get inlineTextTemplate_169e482cbbd960b7 => 'QZXVAR0QZX eklendi';

  @override
  String get inlineTextTemplate_10d0ba33ae09b3a4 => 'Politikası: QZXVAR0QZX · Bugün: QZXVAR1QZX';

  @override
  String get inlineTextTemplate_1ec56334a0b24b7c => '↑ QZXVAR0QZX Mbps';

  @override
  String get inlineTextTemplate_e61e185de8f8a9d7 => 'Bağlantı kesilemedi: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_d6975653ba21c6a2 => 'Daima açık VPN güncellenemedi: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_c0671aa2f2dd814a => 'Download & Update';

  @override
  String get inlineTextTemplate_94fa013c0e7b11f3 => 'QZXVAR0QZX\'te Gelişmiş Sistem Yönlendirmesi';

  @override
  String get inlineTextTemplate_4511036a54304f80 => 'Update Download Complete';

  @override
  String get inlineAttributeTemplate_73b6e48a1b552d11 => 'Later';

  @override
  String get inlineAttributeTemplate_2e5f79bb94a8c40b => 'Checking...';

  @override
  String get inlineAttributeTemplate_c1c1009d3f37ec05 => 'Update';

  @override
  String get inlineAttributeTemplate_a4738b604a205c2e => 'Check Updates';

  @override
  String get inlineAttributeTemplate_ccccab7c5d91fcc1 => 'Release Highlights';

  @override
  String get inlineAttributeTemplate_3e695daee969126c => 'Package installer launched. Tap below if you need to relaunch.';

  @override
  String get inlineAttributeTemplate_be6ee118f6ce86a8 => 'Downloading Update...';

  @override
  String get inlineAttributeTemplate_2f1118ed7cdb58dc => '\"QZXVAR0QZX\" [QZXVAR1QZX] filtresiyle eşleşen günlük satırı yok.';

  @override
  String get inlineAttributeTemplate_005ef7725a64c7ed => 'New Version Available';

  @override
  String get inlineAttributeTemplate_fd67fb8b214d0251 => 'Harmoney Update Available';

  @override
  String get inlineAttributeTemplate_0c16e4802957bf2a => 'Update Interrupted';

  @override
  String get inlineAttributeTemplate_1d653fc4503ec979 => 'The update will download and install directly inside Harmoney.';

  @override
  String get inlineAttributeTemplate_48845bff334a50a5 => 'Dismiss';

  @override
  String get inlineAttributeTemplate_c0671aa2f2dd814a => 'Download & Update';

  @override
  String get inlineAttributeTemplate_4a4177e796293af3 => '⚠ Uyarı: QZXVAR0QZX';

  @override
  String get inlineAttributeTemplate_fede49e2e980819c => 'Wi-Fi QR URI: QZXVAR0QZX';

  @override
  String get inlineAttributeTemplate_4511036a54304f80 => 'Update Download Complete';

  @override
  String get inlineAttributeTemplate_b0e17c2810653b13 => 'Install Now';

  @override
  String get appString_AboutUs => 'Hakkımızda';

  @override
  String get appString_AboutDescription => 'Harmoney, Harmoney tarafından geliştirilmiştir; güvenli, hızlı ve sınırsız internet erişimi sağlayan modern bir VPN çözümüdür.';

  @override
  String get appString_Connect => 'Bağlan';

  @override
  String get appString_Disconnect => 'Bağlantıyı Kes';

  @override
  String get appString_Connected => 'Bağlandı';

  @override
  String get appString_Disconnected => 'Bağlantı Kesildi';

  @override
  String get appString_Locations => 'Konumlar';

  @override
  String get appString_Statistics => 'Hız ve İstatistik';

  @override
  String get appString_SplitTunnel => 'Bölünmüş Tünel';

  @override
  String get appString_Hotspot => 'Erişim Noktası';

  @override
  String get appString_Protection => 'Güvenlik';

  @override
  String get appString_LeakProtection => 'Veri sızıntısı koruması';

  @override
  String get appString_SystemSafeguards => 'Sistem korumaları';

  @override
  String get appString_CountryBypass => 'Ülke atlama';

  @override
  String get appString_Diagnostics => 'Tanılama';

  @override
  String get appString_Settings => 'Ayarlar';

  @override
  String get appString_Connection => 'Bağlantı';

  @override
  String get appString_AutoConnect => 'Otomatik Bağlan';

  @override
  String get appString_AutoConnectSubtitle => 'Desteklenen ağlarda otomatik olarak bağlan';

  @override
  String get appString_KillSwitch => 'Acil Durum Kesicisi';

  @override
  String get appString_KillSwitchSubtitle => 'VPN bağlantısı kesilirse internet erişimini tamamen durdur';

  @override
  String get appString_Protocol => 'Protokol';

  @override
  String get appString_VpnProvider => 'VPN Sağlayıcı';

  @override
  String get appString_ProviderSeparated => 'Çekirdek katman yüksek hız ve güvenlik için ayrılmıştır';

  @override
  String get appString_Privacy => 'Gizlilik';

  @override
  String get appString_DnsLeakProtection => 'Gelişmiş DNS Sızıntı Koruması';

  @override
  String get appString_Ipv6LeakProtection => 'IPv6 Sızıntı Koruması';

  @override
  String get appString_Appearance => 'Görünüm';

  @override
  String get appString_System => 'Sistem';

  @override
  String get appString_Light => 'Açık';

  @override
  String get appString_Dark => 'Koyu Modern';

  @override
  String get appString_Language => 'Uygulama Dili';

  @override
  String get appString_LoadApps => 'Uygulamaları Yükle';

  @override
  String get appString_SearchingApps => 'Uygulama ara...';

  @override
  String get appString_BypassIran => 'Yerel Siteleri Doğrudan Bağla';

  @override
  String get appString_ConnectedTo => 'Bağlanılan:';

  @override
  String get directFa_26fc31773fa51ad0 => 'Split Tunnel & Bypass';

  @override
  String get directEn_c982c0c4cfe9c935 => 'Split Tunnel & Bypass';

  @override
  String get directFa_1017a10a74fc8b4c => 'Country & App Bypass';

  @override
  String get directEn_ed95556c5c93ded1 => 'Country & App Bypass';

  @override
  String get directFa_39dbd18df3aa1b73 => 'Security & Kill Switch';

  @override
  String get directEn_0efd36b42d93a9cf => 'Security & Kill Switch';

  @override
  String get directFa_fceec8184bae394a => 'Hotspot Shield';

  @override
  String get directEn_affe75e7c781f044 => 'Hotspot Shield';

  @override
  String get directFa_6a291c533e65eac9 => 'Traffic Analytics';

  @override
  String get directEn_26bce86e894398f0 => 'Traffic Stats';

  @override
  String get directFa_149bc72261ed557a => 'VPN Hotspot Sharing (Windows ICS)';

  @override
  String get directEn_e9d51941d0c1f37b => 'VPN Hotspot Sharing (Windows ICS)';

  @override
  String get directFa_ffc1a00b2cd1bd6a => 'Share secure encrypted tunnel with phones & tablets';

  @override
  String get directEn_8693a5d72c6b23fa => 'Share secure encrypted tunnel with phones & tablets';

  @override
  String get directFa_6889a68d04894859 => 'Enable Hotspot Sharing (ICS)';

  @override
  String get directEn_f24d839a275e6eaa => 'Enable Hotspot Sharing (ICS)';

  @override
  String get directFa_3bcda1eec5106a5d => 'Configures Windows ICS for the VPN adapter when Mobile Hotspot is active. The app verifies the ICS binding; client Internet traffic still needs an end-to-end check.';

  @override
  String get directEn_9f658c229a11bef6 => 'Configures Windows ICS for the VPN adapter when Mobile Hotspot is active. The app verifies the ICS binding; client Internet traffic still needs an end-to-end check.';

  @override
  String get directFa_9bbd9bac026872c1 => 'Hardware Profile: Dell Latitude 7210 & Intel / Cellular LTE';

  @override
  String get directEn_9e4a7faff61f59aa => 'Hardware Profile: Dell Latitude 7210 & Intel / Cellular LTE';

  @override
  String get directFa_50c65a3d13ee268a => '• Automatic MTU optimization to 1350 preventing packet fragmentation.\n• Intelligent dual-uplink support (Intel Wi-Fi + Cellular LTE).\n• Zero client-side software configuration needed on connected devices.';

  @override
  String get directEn_0aa0eafed86db230 => '• Automatic MTU optimization to 1350 preventing packet fragmentation.\n• Intelligent dual-uplink support (Intel Wi-Fi + Cellular LTE).\n• Zero client-side software configuration needed on connected devices.';

  @override
  String get directFa_62610231d271d134 => 'Open Mobile Hotspot';

  @override
  String get directEn_0acb9208ef119b21 => 'Open Mobile Hotspot';

  @override
  String get directFa_3a920a034280df3b => 'Hotspot sharing preference saved.';

  @override
  String get directEn_ad208643ab98407d => 'Hotspot sharing preference saved.';

  @override
  String get directFa_674da212761c9897 => 'Save preference';

  @override
  String get directEn_fa174cea0ac4357d => 'Save preference';

  @override
  String get directFa_0b29754285a30eb5 => 'servers';

  @override
  String get directEn_8e3dc1afbc3ec556 => 'servers';

  @override
  String get directFa_7b7b1f9f056db6a2 => 'Tap to view and select';

  @override
  String get directEn_2cc9305c93b06b14 => 'Tap to view and select';

  @override
  String get directFa_3f513f6f165abe3a => 'Pinging';

  @override
  String get directEn_1575703aa4004510 => 'Pinging';

  @override
  String get directFa_bfe619723f7415af => 'Run a manual latency check';

  @override
  String get directEn_ee7ff7f0b25192c5 => 'Run a manual latency check';

  @override
  String get directFa_047e26dc40ad2e6c => 'Ping all';

  @override
  String get directEn_c749d615571ec59b => 'Ping all';

  @override
  String get directFa_9eb2b971b235433d => ' · No response';

  @override
  String get directEn_52d81add0d0bba64 => ' · No response';

  @override
  String get directFa_490a4c57bf7ab538 => 'CONNECTED';

  @override
  String get directEn_22965568d22a14ee => 'Connected';

  @override
  String get directFa_c5ddc53614e359dd => 'Not compatible with this device';

  @override
  String get directEn_5de8c3898d69b278 => 'Not compatible with this device';

  @override
  String get directFa_631b37d4472bc4af => 'Locations & Routes';

  @override
  String get directEn_bbf3d191d555c872 => 'Locations & Routes';

  @override
  String get directFa_19062eabc808d3cb => 'Smart routing and personal subscriptions';

  @override
  String get directEn_d0e13ceb47c44a7f => 'Smart routing and personal subscriptions';

  @override
  String get directFa_dfb5490308844c12 => 'Lightweight Firefox VPN tunnel';

  @override
  String get directEn_49a2fc4df1b8bad5 => 'Lightweight Firefox VPN tunnel';

  @override
  String get directFa_0aad2895c1e3bafe => 'Select connection service';

  @override
  String get directEn_46b5d935b82dd8e0 => 'Select connection service';

  @override
  String get directFa_8f4835903634041e => 'Firefox VPN protocol';

  @override
  String get directEn_034fc31b30e178f0 => 'Firefox VPN protocol';

  @override
  String get directFa_1a192f60ba3a8289 => 'Fetching & validating feeds…';

  @override
  String get directEn_13e340711e620242 => 'Fetching & validating feeds…';

  @override
  String get directFa_82fc0e4970c24375 => 'Offline; preserved last healthy config';

  @override
  String get directEn_4b55315990907923 => 'Offline; preserved last healthy config';

  @override
  String get directFa_19df9dbf599af948 => 'Harmoney bundled sources';

  @override
  String get directEn_622490dc634188e3 => 'Harmoney bundled sources';

  @override
  String get directFa_72eadf7b1642b492 => 'Refresh';

  @override
  String get directEn_0e91610117029a62 => 'Refresh';

  @override
  String get directFa_d129f6c328ebc070 => 'Never';

  @override
  String get directEn_6300ef800bb88429 => 'Never';

  @override
  String get directFa_bd917b26118b13c4 => 'Just now';

  @override
  String get directEn_66f53417d3b7797a => 'Just now';

  @override
  String get directFa_d2a9c0e9a77e362f => 'Ping all visible';

  @override
  String get directEn_49ee72faa5b743f7 => 'Ping all visible';

  @override
  String get directFa_54a0cc043e8b2469 => 'Ping All';

  @override
  String get directEn_5e414ee0c5da2dde => 'Ping All';

  @override
  String get directFa_cc03494b29df4f8b => 'Refresh Catalog';

  @override
  String get directEn_a7a480dfb660e610 => 'Refresh Catalog';

  @override
  String get directFa_15270886eaddc37f => 'All';

  @override
  String get directEn_a52ace420f2175d0 => 'All';

  @override
  String get directFa_bbe41ad560aa142b => 'Recent';

  @override
  String get directEn_690dbe9dc0993c42 => 'Recent';

  @override
  String get directFa_5f2e4ba5353998cd => 'Smart & Warp';

  @override
  String get directEn_e96958fdea5d076e => 'Smart & Warp';

  @override
  String get directFa_52ae64718fc96a07 => 'Stealth';

  @override
  String get directEn_526a40a447ddd7aa => 'Stealth';

  @override
  String get directFa_d49e29aa06fa679a => 'Favorites';

  @override
  String get directEn_7a1f2a83aca9a081 => 'Favorites';

  @override
  String get directFa_be1aa9e3bcbefea8 => 'Lowest Ping';

  @override
  String get directEn_d96e4d444648ad39 => 'Lowest Ping';

  @override
  String get directFa_b7280ab58d1ef0d3 => 'Online Only';

  @override
  String get directEn_39abe2a6fc13b2b2 => 'Online Only';

  @override
  String get directEn_630c2f1c0ee1b8d7 => 'ACTIVE';

  @override
  String get directFa_c6bdd72afead66be => 'Recent';

  @override
  String get directFa_b1fc7e540a30aaf8 => 'No favorite servers yet';

  @override
  String get directEn_dc70c82d78d1c0e8 => 'No favorite servers yet';

  @override
  String get directFa_49320fa08539eb81 => 'Star servers to pin them here for fast access';

  @override
  String get directEn_9571e3d9d6f0c728 => 'Star servers to pin them here for fast access';

  @override
  String get directFa_42527803296e602f => 'No recent connection history';

  @override
  String get directEn_d09e302f1c0274ba => 'No recent connection history';

  @override
  String get directFa_0fc8187b4a7f9368 => 'Servers you connect to will appear here for 1-tap reconnect';

  @override
  String get directEn_f30337f6760cbc52 => 'Servers you connect to will appear here for 1-tap reconnect';

  @override
  String get directFa_1fe15ae1e09b6e2c => 'No servers match your criteria';

  @override
  String get directEn_5833dd21953633eb => 'No servers match your criteria';

  @override
  String get directFa_2b63b2b0981c49df => 'Clear search term or reset filters';

  @override
  String get directEn_920eea58ed6b97ac => 'Clear search term or reset filters';

  @override
  String get directFa_3b855c73b085a016 => 'Show All Servers';

  @override
  String get directEn_6bcc8512de553613 => 'Show All Servers';

  @override
  String get directFa_d5b3c30550d09e4c => 'Country IPv4 ranges bypass the VPN after reconnecting. App bypass uses the Windows physical interface and requires the Harmoney service.';

  @override
  String get directEn_d86322c4ceb937de => 'Country IPv4 ranges bypass the VPN after reconnecting. App bypass uses the Windows physical interface and requires the Harmoney service.';

  @override
  String get directFa_df9d57a055ecc92b => 'Per-app bypass';

  @override
  String get directEn_e7977ed18b1df209 => 'Per-app bypass';

  @override
  String get directFa_a94787ee2df7791b => 'Selected apps use the physical network directly. Other apps continue using the VPN.';

  @override
  String get directEn_36230e6a755f25c0 => 'Selected apps use the physical network directly. Other apps continue using the VPN.';

  @override
  String get directFa_6e26cf4eaf584275 => 'Enable app bypass';

  @override
  String get directEn_0234c7f3ac8b5b71 => 'Enable app bypass';

  @override
  String get directFa_be1c8cef94eaf799 => 'Add at least one application to turn this on.';

  @override
  String get directEn_81e9f4e64a840785 => 'Add at least one application to turn this on.';

  @override
  String get directFa_1ab679752901fb30 => 'Add application (.exe)';

  @override
  String get directEn_50829e8639527356 => 'Add application (.exe)';

  @override
  String get directFa_6badcac8c181d253 => 'Settings';

  @override
  String get directEn_74a883a037bc227f => 'Settings';

  @override
  String get directFa_3b1a615eb46d3552 => 'Manage connection, security, and appearance';

  @override
  String get directEn_61118b57b609e8fd => 'Manage connection, security, and appearance';

  @override
  String get directFa_3f50db43516612df => 'Connection & network';

  @override
  String get directEn_30df82f8484e7683 => 'Connection & network';

  @override
  String get directFa_e107b6a1c6237873 => 'Choose the VPN service for your connection';

  @override
  String get directEn_910a1f4713f13d8e => 'Choose the VPN service for your connection';

  @override
  String get directFa_58315650533b0b3b => 'VPN protocol';

  @override
  String get directEn_7686b2c38e140183 => 'VPN protocol';

  @override
  String get directFa_2a5bdeae1adad66c => 'Available options for this service';

  @override
  String get directEn_cedbc131160b33f1 => 'Available options for this service';

  @override
  String get directFa_16aebe854ffb5f38 => 'Privacy & security';

  @override
  String get directEn_f38d325999eb36a6 => 'Privacy & security';

  @override
  String get directFa_a89854802b5f20cf => 'Network protections configured for this device';

  @override
  String get directEn_be15fa8563e40cba => 'Network protections configured for this device';

  @override
  String get directFa_1409b5d4b2651bab => 'Routes DNS requests through the VPN tunnel';

  @override
  String get directEn_b613c94bf91b3fc9 => 'Routes DNS requests through the VPN tunnel';

  @override
  String get directFa_8195f49a5b2e17b2 => 'Prevents unrouted IPv6 traffic from bypassing the tunnel';

  @override
  String get directEn_1cdef3c7ac0432a7 => 'Prevents unrouted IPv6 traffic from bypassing the tunnel';

  @override
  String get directFa_0e983de7a97d3ebc => 'Restore network';

  @override
  String get directEn_8bd8660e60b766d4 => 'Restore network';

  @override
  String get directFa_be441169827bd41f => 'Restore routes and traffic rules if the network is stuck';

  @override
  String get directEn_0af7a160977315f6 => 'Restore routes and traffic rules if the network is stuck';

  @override
  String get directFa_7598b46f5cf1fc09 => 'Restore';

  @override
  String get directEn_a76e13b9839270eb => 'Restore';

  @override
  String get directFa_ba59a5c62a44328b => 'Automation & profiles';

  @override
  String get directEn_e59064ae08e6a067 => 'Automation & profiles';

  @override
  String get directFa_48fd53e2af663b4a => 'Startup behavior and imported VPN configurations';

  @override
  String get directEn_97bcdad71573d6c3 => 'Startup behavior and imported VPN configurations';

  @override
  String get directFa_69a843018034c170 => 'Launch at system startup';

  @override
  String get directEn_3f1c0972eed8648e => 'Launch at system startup';

  @override
  String get directFa_47133f15d25244d1 => 'Start Harmoney when you sign in';

  @override
  String get directEn_0d5ac9a1f2d12cde => 'Start Harmoney when you sign in';

  @override
  String get directFa_daf6a3deef1f3b02 => 'Always-on VPN';

  @override
  String get directEn_58b2c361864f4c09 => 'Always-on VPN';

  @override
  String get directFa_70bbad1ef3799c29 => 'Reconnect through the system watchdog';

  @override
  String get directEn_22e25c3212f145b0 => 'Reconnect through the system watchdog';

  @override
  String get directFa_9229a87b05a54019 => 'Opens Android VPN settings to configure Always-on';

  @override
  String get directEn_bce686c9ff4b4f85 => 'Opens Android VPN settings to configure Always-on';

  @override
  String get directFa_ad7388a14026319e => 'Appearance';

  @override
  String get directEn_3907fa7f80722a6f => 'Appearance';

  @override
  String get directFa_486db8686a654fbe => 'Choose the app theme and language';

  @override
  String get directEn_cb0d1cffba7882cc => 'Choose the app theme and language';

  @override
  String get directFa_90ec529f45409145 => 'Theme';

  @override
  String get directEn_efb52e7172b77731 => 'Theme';

  @override
  String get directFa_bcbedc248a089ce8 => 'App language';

  @override
  String get directEn_b8352b44a588721c => 'App language';

  @override
  String get directFa_88acd614f1d3e7b2 => 'Diagnostics';

  @override
  String get directEn_268f14bbfe119c1e => 'Diagnostics';

  @override
  String get directFa_9891a6dacb577296 => 'Connection events, network errors, and technical logs';

  @override
  String get directEn_2cd958314044a442 => 'Connection events, network errors, and technical logs';

  @override
  String get directFa_3c77e77837fbd3a5 => 'Technical logs';

  @override
  String get directEn_1c3d7cf2bec01443 => 'Technical logs';

  @override
  String get directFa_fb0c92377fa9ebf2 => 'View and filter application logs';

  @override
  String get directEn_1a06ce3cb511774e => 'View and filter application logs';

  @override
  String get directFa_d2c8a80d171eaac0 => 'Open';

  @override
  String get directEn_ed077f3d8125d60d => 'Open';

  @override
  String get directFa_84bf1721cbaf0414 => 'Harmoney Anti-Censorship Core';

  @override
  String get directEn_4f5845ea70794fc8 => 'Harmoney Anti-Censorship Core';

  @override
  String get directEn_1f914c4386c0676e => 'CONNECTED';

  @override
  String get directFa_9dbd12e5e9f378e2 => 'DISCONNECTED';

  @override
  String get directEn_5541de9515522b98 => 'DISCONNECTED';

  @override
  String get directFa_5391ea668eee238e => 'Routes from Xray, WARP and MASQUE configurations. Connection is shown after traffic verification.';

  @override
  String get directEn_92723a5ff9689c3d => 'Routes from Xray, WARP and MASQUE configurations. Connection is shown after traffic verification.';

  @override
  String get directFa_feb86040674f19da => 'Manage Firefox VPN Account';

  @override
  String get directEn_316f766fb0bc3a72 => 'Manage Firefox VPN Account';

  @override
  String get directFa_da40aa3623e41c95 => 'Remaining traffic:';

  @override
  String get directEn_4968fc7fef5ea571 => 'Remaining traffic:';

  @override
  String get directFa_da8c51e206680bba => 'Refresh status & quota';

  @override
  String get directEn_7af2f7454f3b55aa => 'Refresh status & quota';

  @override
  String get directFa_f5afe95a8fd7ddc6 => 'Query latest session and traffic quota';

  @override
  String get directEn_8035283793ddc0b5 => 'Query latest session and traffic quota';

  @override
  String get directFa_42337406cedc1429 => 'Re-login to account';

  @override
  String get directEn_a836bff92bbc5af0 => 'Re-login to account';

  @override
  String get directFa_e61fefa6ad7996d4 => 'Renew session tokens or switch account';

  @override
  String get directEn_a899ea0cfb536e60 => 'Renew session tokens or switch account';

  @override
  String get directFa_bf5696ba3389269b => 'Logout';

  @override
  String get directEn_d0527e4b3d658351 => 'Logout';

  @override
  String get directFa_ad503541892485c7 => 'Clear stored credentials from this device';

  @override
  String get directEn_c4b662bd95db40f1 => 'Clear stored credentials from this device';

  @override
  String get directFa_3ed02792f04eb5b4 => 'Firefox VPN Account';

  @override
  String get directEn_229b05d20a6d2706 => 'Firefox VPN Account';

  @override
  String get directFa_25384e5227763ffa => 'Checking…';

  @override
  String get directEn_ec963ffc911b8401 => 'Checking…';

  @override
  String get directFa_f14154be5d9988d7 => 'Session Expired';

  @override
  String get directEn_7ae00a283ea9b728 => 'Session Expired';

  @override
  String get directFa_45aa400fa5168a7b => 'Logged In';

  @override
  String get directEn_9b13e877e4aa90a7 => 'Logged In';

  @override
  String get directFa_55217fc0011924d2 => 'Login Required';

  @override
  String get directEn_88712c434b491bce => 'Login Required';

  @override
  String get directFa_44fb79ae8debab9c => 'Checking account…';

  @override
  String get directEn_d18f4156fea49644 => 'Checking account…';

  @override
  String get directFa_1e5f5243758c6f38 => 'Security session expired; please sign in again to use servers.';

  @override
  String get directEn_fa488105cb65db88 => 'Security session expired; please sign in again to use servers.';

  @override
  String get directFa_0b8e3e351c70fd58 => 'Sign in to activate Firefox tunnel and view data quota.';

  @override
  String get directEn_f493cd9c7ae396ec => 'Sign in to activate Firefox tunnel and view data quota.';

  @override
  String get directFa_65f6ae6ff5ae8280 => 'Establishing secure tunnel…';

  @override
  String get directEn_24b8d9733417f7f2 => 'Establishing secure tunnel…';

  @override
  String get directFa_2825bd47934b892f => 'VPN tunnel inactive · Ready to connect';

  @override
  String get directEn_ee73ed2931582286 => 'VPN tunnel inactive · Ready to connect';

  @override
  String get directFa_a032c52ee18734be => 'Traffic Quota';

  @override
  String get directEn_afdd44031ab46f34 => 'Traffic Quota';

  @override
  String get directFa_61a760cc9666bc9b => 'Monthly Allowance';

  @override
  String get directEn_659e50811965fe84 => 'Monthly Allowance';

  @override
  String get directFa_b160cc84c236bc55 => 'Quota information unavailable';

  @override
  String get directEn_893e490d64407b8e => 'Quota information unavailable';

  @override
  String get directFa_06922cd515293cd4 => 'Unlimited quota';

  @override
  String get directEn_23d5d93cf5f11e17 => 'Unlimited quota';

  @override
  String get directFa_80a85438cf023e19 => 'GiB';

  @override
  String get directEn_66a1561b84b46372 => 'GiB';

  @override
  String get directFa_a624a1e41ffdc6d6 => ' of ';

  @override
  String get directEn_a4282e4b2298b90b => ' of ';

  @override
  String get directFa_4b329f46e3e4aa50 => 'remaining';

  @override
  String get directEn_43e3ece73ff8f4eb => 'remaining';

  @override
  String get directFa_6d2ae6f38c3f09cd => 'Sign In';

  @override
  String get directEn_c90fdfab474bdd3e => 'Log in to account';

  @override
  String get directFa_9b009e657294963a => 'Re-login';

  @override
  String get directEn_fbfd8ce759281a7c => 'Re-login';

  @override
  String get directFa_47018eca7a6a198e => 'Manage Account';

  @override
  String get directEn_203229774cceb5f3 => 'Manage Account';

  @override
  String get directFa_39db927c23ae2f24 => 'Logout';

  @override
  String get directFa_447aac2e6e36c632 => 'Refresh Status';

  @override
  String get directEn_72fe71cb37d209d2 => 'Refresh Status';

  @override
  String get directEn_bcc0bcc9140b0c97 => 'Sign In';

  @override
  String get directFa_8ac2798171b7f59a => 'Check status';

  @override
  String get directEn_69cd3590300a68c6 => 'Check status';

  @override
  String get directFa_fe9c7660a2b6752a => 'Automatic';

  @override
  String get directEn_d461a493a3753877 => 'Automatic';

  @override
  String get directFa_65feb3156825dbc3 => 'Automatic provider-managed routing';

  @override
  String get directEn_3e5404c2c8a5d4f7 => 'Automatic provider-managed routing';

  @override
  String get directFa_0728ba5430a590a1 => 'Monthly Data Quota';

  @override
  String get directEn_f6be68de3c8d5e7d => 'Monthly Data Quota';

  @override
  String get directFa_b496c7ee3eea90bc => 'You will receive visual alerts when reaching this limit.';

  @override
  String get directEn_243a20f9ba6c2892 => 'You will receive visual alerts when reaching this limit.';

  @override
  String get directFa_3aa40b685220c3cb => 'Unlimited (Off)';

  @override
  String get directEn_4bd0e4ba0e817d11 => 'Unlimited (Off)';

  @override
  String get directFa_fa7af603d430b209 => 'Cancel';

  @override
  String get directEn_19766ed6ccb2f4a3 => 'Cancel';

  @override
  String get directFa_609b20177a3148b2 => 'Save Quota';

  @override
  String get directEn_8e1b786c7913210c => 'Save Quota';

  @override
  String get directEn_4bfa799fae21b467 => 'Traffic Analytics';

  @override
  String get directFa_b8b979fad05a28d9 => 'Live bandwidth, data accounting & quota';

  @override
  String get directEn_2eb0c5a3ce65868c => 'Live bandwidth, data accounting & quota';

  @override
  String get directFa_e6522eb9b3c2254c => 'Live Active';

  @override
  String get directEn_a0b16ccf9021fc82 => 'Live Active';

  @override
  String get directFa_08914752d2e02ff9 => 'Waiting for VPN';

  @override
  String get directEn_2693034906c0e6f9 => 'Waiting for VPN';

  @override
  String get directFa_38a3d2526a8bcc84 => 'Live Real-Time Speed';

  @override
  String get directEn_c6c2daab1f7d2fe5 => 'Live Real-Time Speed';

  @override
  String get directFa_9bf13dfa15fb680e => 'Download';

  @override
  String get directEn_2eb993f9bc93c5ff => 'DL';

  @override
  String get directFa_2ce1cec62671ae15 => 'Upload';

  @override
  String get directEn_6138f40c9673bed1 => 'UL';

  @override
  String get directFa_cc361d9901ffdf37 => 'Monthly Data Quota';

  @override
  String get directFa_b0de3b412705cb35 => 'Set Quota';

  @override
  String get directEn_a429cd15905e58a5 => 'Set Quota';

  @override
  String get directFa_c25fdb7da6c13c3a => 'used';

  @override
  String get directEn_f839161355091fcd => 'used';

  @override
  String get directFa_c17283824713e914 => 'No Limit Set';

  @override
  String get directEn_2de8796023cbb4c7 => 'No Limit Set';

  @override
  String get directFa_61b4fadd6541d1c0 => 'Today';

  @override
  String get directEn_2b065c7c9ce466e5 => 'Today';

  @override
  String get directFa_fc454815fc7e587d => 'Peak Speed';

  @override
  String get directEn_ccbb73524b4bd4ee => 'Peak Speed';

  @override
  String get directFa_d39fe430fa149d24 => 'Highest recorded';

  @override
  String get directEn_0debfca2599549f2 => 'Highest recorded';

  @override
  String get directFa_ad9ba5d4f5d3620f => 'This Month';

  @override
  String get directEn_64367736022306e3 => 'This Month';

  @override
  String get directFa_d7efa0cd9804f3a3 => 'Lifetime Total';

  @override
  String get directEn_722808dd53ec1823 => 'Lifetime Total';

  @override
  String get directFa_ee086cbab6feeb75 => 'All-time volume';

  @override
  String get directEn_20e93f7caa1a7a5c => 'All-time volume';

  @override
  String get directFa_c709d51a733c7d0b => 'Session Duration';

  @override
  String get directEn_ad4b77a68783ec24 => 'Session Duration';

  @override
  String get directFa_3ed03a3af2ebf355 => 'Session Download:';

  @override
  String get directEn_90f46423c0074765 => 'Session Download:';

  @override
  String get directFa_bca2becadd374c69 => 'Session Upload:';

  @override
  String get directEn_4d9bfca28655ee45 => 'Session Upload:';

  @override
  String get directFa_048be696dea10d04 => 'Last Speed Benchmark:';

  @override
  String get directEn_2faba03e2b8726a9 => 'Last Speed Benchmark:';

  @override
  String get directFa_f07a81a062535ff7 => 'Unknown';

  @override
  String get directEn_b764cdc0eab71374 => 'Unknown';

  @override
  String get directFa_b8d890311eb66f8b => 'Automatic route';

  @override
  String get directEn_58f885c3d5750c90 => 'Automatic route';

  @override
  String get directFa_627f8d2a81499747 => 'Verified Secure Tunnel';

  @override
  String get directEn_435483eb4a848f87 => 'Verified Secure Tunnel';

  @override
  String get directFa_d115b5686b17f628 => 'Exit IP';

  @override
  String get directEn_cea9bb520a68321d => 'Exit IP';

  @override
  String get directFa_a3fa2a3ffcb94859 => 'Online';

  @override
  String get directEn_0d21bd52022ca7f7 => 'Online';

  @override
  String get directFa_b883b4839aacf6e7 => 'Measuring...';

  @override
  String get directEn_e7c955a5ec17dda2 => 'Measuring...';

  @override
  String get directFa_01fff4b387cb6493 => 'Excellent';

  @override
  String get directEn_0dc8ee555c28ec1b => 'Excellent';

  @override
  String get directFa_056e4427b316f2c7 => 'Good';

  @override
  String get directEn_c939327ca16dcf97 => 'Good';

  @override
  String get directFa_42a5dadf6e451488 => 'Fair';

  @override
  String get directEn_f7b19afcde965ea4 => 'Fair';

  @override
  String get directFa_3865275fd105a5b8 => 'Tap to run full speed test';

  @override
  String get directEn_b8d5e190fa4127c4 => 'Tap to run full speed test';

  @override
  String get directEn_d6eafe8235910042 => 'Download';

  @override
  String get directEn_865e89de78d94c74 => 'Upload';

  @override
  String get directFa_ff9d6eaa4d416020 => 'Tap to re-test latency';

  @override
  String get directEn_9ef6777f1d140309 => 'Tap to re-test latency';

  @override
  String get directFa_6c85ce5d5c3eb500 => 'Copy Public IP';

  @override
  String get directEn_caf4d6e51756401d => 'Copy Public IP';

  @override
  String get directFa_a47a3ca2c3fb77ce => 'Copied!';

  @override
  String get directEn_ea61bc15688d1e48 => 'Copied!';

  @override
  String get directFa_b6cd8e356ae4de3e => 'Domestic Bypass';

  @override
  String get directEn_1214c275435c3c13 => 'Domestic Bypass';

  @override
  String get directFa_2841f70e40d3118f => 'Direct IR routes';

  @override
  String get directEn_179a9a0e2cfce115 => 'Direct IR routes';

  @override
  String get directFa_b4cab70060e554b3 => 'Kill Switch';

  @override
  String get directEn_006b49290aa86bfe => 'Kill Switch';

  @override
  String get directFa_1633c46938431a54 => 'Active';

  @override
  String get directEn_92340695899bd2d8 => 'Active';

  @override
  String get directFa_4e67bd8e348260b0 => 'Disabled';

  @override
  String get directEn_75081b593d15cf6e => 'Disabled';

  @override
  String get directFa_120c9c6bd8826c8b => 'Speed Test';

  @override
  String get directEn_d23ced7772a783f3 => 'Speed Test';

  @override
  String get directFa_3e67ba9b0445249e => 'Measure latency & speed';

  @override
  String get directEn_948111705a82a507 => 'Measure latency & speed';

  @override
  String get directFa_d5c66bbea9d37a9c => 'Connection service';

  @override
  String get directEn_e1f42d830cee8336 => 'Connection service';

  @override
  String get directFa_48c1182b09375569 => 'Connected & Protected';

  @override
  String get directEn_105e6388aad6ff7f => 'Connected & Protected';

  @override
  String get directFa_e2c8f657fd596d7d => 'Connecting...';

  @override
  String get directEn_5f04ae9ed6a865bb => 'Connecting...';

  @override
  String get directFa_1a8adc1da26270cc => 'Authenticating & Bypassing...';

  @override
  String get directEn_1d18406321d2db26 => 'Authenticating & Bypassing...';

  @override
  String get directFa_12df5a9cc276f2c3 => 'Connection Failed';

  @override
  String get directEn_42aa4e7bc5d2c21a => 'Connection Failed';

  @override
  String get directFa_cd85b4ceda3cc131 => 'Disconnecting...';

  @override
  String get directEn_cb5a85cad9bd34c5 => 'Disconnecting...';

  @override
  String get directFa_9b54440688493c0e => 'Ready to Connect';

  @override
  String get directEn_5883e493fc35afe6 => 'Ready to Connect';

  @override
  String get directFa_f941f415804ba6bc => 'All your traffic is encrypted and anonymous';

  @override
  String get directEn_cd289597cdb36a8e => 'All your traffic is encrypted and anonymous';

  @override
  String get directFa_c1c8e35e7a1e6ab5 => 'Finding the fastest censorship-resistant route...';

  @override
  String get directEn_fc7f3ba24f1e9374 => 'Finding the fastest censorship-resistant route...';

  @override
  String get directFa_545c3b36cf6a9b19 => 'Tap the button to reconnect';

  @override
  String get directEn_c00c5efaa984cbb0 => 'Tap the button to reconnect';

  @override
  String get directFa_19b98ac54207bf43 => 'Tap the shield button to secure your internet';

  @override
  String get directEn_dc50817ae538ef68 => 'Tap the shield button to secure your internet';

  @override
  String get directFa_ea55a64adb57f89d => 'Automatic Firefox VPN server';

  @override
  String get directEn_a84cdc7941aa150d => 'Automatic Firefox VPN server';

  @override
  String get directFa_3c408aa10a3a59a2 => 'Harmoney Smart Route';

  @override
  String get directEn_17910d2c8cda2576 => 'Harmoney Smart Route';

  @override
  String get directFa_8f195663090dbd82 => 'An available server is chosen when you connect';

  @override
  String get directEn_0666050624c4726b => 'An available server is chosen when you connect';

  @override
  String get directFa_787659ec3bcfb8a4 => 'Speed report copied to clipboard!';

  @override
  String get directEn_f5af9ab211b447cd => 'Speed report copied to clipboard!';

  @override
  String get directFa_6d3beddaa5bcf6ea => 'Speed Test History';

  @override
  String get directEn_c3a6d1c87fa8d4bb => 'Speed Test History';

  @override
  String get directFa_f2730ebc51f8b5f4 => 'Clear';

  @override
  String get directEn_83b12c2216efb4fd => 'Clear';

  @override
  String get directFa_0a48e042ec0bc4e0 => 'No speed tests recorded yet.';

  @override
  String get directEn_df578dfdf0dafa9a => 'No speed tests recorded yet.';

  @override
  String get directFa_147f59b73fb11974 => 'Speed & Grade';

  @override
  String get directEn_f6e4e9eb494ae1e4 => 'Speed & Grade';

  @override
  String get directFa_cad272ec0da708d2 => 'Live Traffic';

  @override
  String get directEn_4e053f26797a1b12 => 'Live Traffic';

  @override
  String get directFa_1b248f96a0d6123f => 'Diagnostics';

  @override
  String get directFa_afc81625f67a81d4 => 'Ping';

  @override
  String get directEn_6a4c3a4483b04488 => 'Ping';

  @override
  String get directFa_3381d5e424186c39 => 'Jitter';

  @override
  String get directEn_91fbe4c855fbe075 => 'Jitter';

  @override
  String get directFa_b31ec87c31b48943 => 'Smart Service Suitability';

  @override
  String get directEn_e17b6227325e1a8d => 'Smart Service Suitability';

  @override
  String get directFa_1d79e493a5f0af51 => 'Gaming';

  @override
  String get directEn_0fadfa22881467dc => 'Gaming';

  @override
  String get directFa_e8622ea6a8536d1c => 'Streaming';

  @override
  String get directEn_a951c5945635e2d3 => 'Streaming';

  @override
  String get directFa_9dbabd2760d00055 => 'No Buffering';

  @override
  String get directEn_7c2521637f81edab => 'No Buffering';

  @override
  String get directFa_ecae75dec1191127 => 'Calls (VoIP)';

  @override
  String get directEn_17ea7be09dfd3486 => 'Calls (VoIP)';

  @override
  String get directFa_023848907db873a8 => 'Zoom & Telegram';

  @override
  String get directEn_48eed22fd9e942cd => 'Zoom & Telegram';

  @override
  String get directFa_d712411ba5c95ecd => 'Stability Index';

  @override
  String get directEn_07561925e24ab3c5 => 'Stability Index';

  @override
  String get directFa_ceb05c63bfc2664a => 'Zero packet loss';

  @override
  String get directEn_2e7e5a988d7ff138 => 'Zero packet loss';

  @override
  String get directFa_45f41f3ef10068e9 => 'Cancel Test';

  @override
  String get directEn_ebf5f31bd3fa8cf4 => 'Cancel Test';

  @override
  String get directFa_b9460b16f1ed426c => 'Start Speed Test';

  @override
  String get directEn_5e0104e1d0dd6cc2 => 'Start Speed Test';

  @override
  String get directFa_ec2855c996f9cbd2 => 'Copy Report';

  @override
  String get directEn_54b8e0c0c268c154 => 'Copy Report';

  @override
  String get directFa_e82a1c223cbe97b6 => 'History';

  @override
  String get directEn_0e76960093379060 => 'History';

  @override
  String get directFaTemplate_994633c2bcedc4a9 => 'Feeds updated & verified (QZXVAR0QZX active)';

  @override
  String get directEnTemplate_b828e6d7441cc143 => 'Feeds updated & verified (QZXVAR0QZX active)';

  @override
  String get directFaTemplate_5239746315c0eb65 => 'QZXVAR0QZX of QZXVAR1QZX feeds verified';

  @override
  String get directEnTemplate_8f43f1183a17a9ee => 'QZXVAR0QZX of QZXVAR1QZX feeds verified';

  @override
  String get directFaTemplate_30d97df5d076bd85 => 'QZXVAR0QZX active feeds ready';

  @override
  String get directEnTemplate_96826d3bc31aa276 => 'QZXVAR0QZX active feeds ready';

  @override
  String get directFaTemplate_fee1d797c43cc69d => 'Last successful update: QZXVAR0QZX';

  @override
  String get directEnTemplate_fded5aac30f3cd2a => 'Last successful update: QZXVAR0QZX';

  @override
  String get directFaTemplate_3c0e143206c640a7 => 'QZXVAR0QZXm ago';

  @override
  String get directEnTemplate_36d18ca5012e48ca => 'QZXVAR0QZXm ago';

  @override
  String get directFaTemplate_c5e58f11bda2617f => 'QZXVAR0QZXh ago';

  @override
  String get directEnTemplate_24aa4c9a230529bd => 'QZXVAR0QZXh ago';

  @override
  String get directFaTemplate_77f98929af010686 => 'QZXVAR0QZX application(s) selected';

  @override
  String get directEnTemplate_d15393d3ecf8ed01 => 'QZXVAR0QZX application(s) selected';

  @override
  String get directFaTemplate_6cb5f3a91c97ab58 => 'QZXVAR0QZX of QZXVAR1QZX GiB';

  @override
  String get directEnTemplate_23034a0887d70ad4 => 'QZXVAR0QZX of QZXVAR1QZX GiB';

  @override
  String get directFaTemplate_827e6929ed952562 => 'Resets: QZXVAR0QZX';

  @override
  String get directEnTemplate_d566a16d104214f0 => 'Resets: QZXVAR0QZX';

  @override
  String get directFa_4767f95a766acad9 => 'profiles imported';

  @override
  String get directEn_fa3e465bd04c98ce => 'profiles imported';

  @override
  String get directFa_6a94bd2919a75602 => 'Importing?';

  @override
  String get directEn_186483a47635ef8b => 'Importing?';

  @override
  String get directFa_7bd1e551fd0c73d1 => 'Import ZIP';

  @override
  String get directEn_cb0bf46bf1e385db => 'Import ZIP';

  @override
  String get directFa_2c0b4ee2a03c434e => 'Manage';

  @override
  String get directEn_5a23444828db654a => 'Manage';

  @override
  String get desktopTrayOpenApplication => 'Uygulamayı Aç';

  @override
  String get desktopTrayChooseServer => 'Sunucu seç…';

  @override
  String get desktopTrayPreferences => 'Tercihler / Ayarlar';

  @override
  String get desktopTrayStartupOptions => 'Başlangıç seçenekleri';

  @override
  String get desktopTrayLaunchOnStartup => 'Sistem açılışında başlat';

  @override
  String get desktopTraySoundEffect => 'Ses efekti';

  @override
  String get desktopTrayStartMinimized => 'Simge durumunda başlat';

  @override
  String get desktopTrayForceClose => 'Tamamen kapat';

  @override
  String get desktopTrayServiceMode => 'Hizmet modu';

  @override
  String get desktopTrayProxyService => 'Proxy hizmeti';

  @override
  String get desktopTraySystemProxy => 'Sistem proxy’si';

  @override
  String get desktopTrayVpnModeUnavailable => 'VPN (kullanılamıyor)';

  @override
  String get desktopTrayExit => 'Çıkış';

  @override
  String get desktopTrayReady => 'Hazır';

  @override
  String get desktopTrayDisconnecting => 'Bağlantı kesiliyor…';

  @override
  String get desktopTrayCancelConnection => 'Bağlantıyı iptal et';

  @override
  String get desktopTrayAutomatic => 'Otomatik';

  @override
  String get desktopTrayError => 'Hata';
}
