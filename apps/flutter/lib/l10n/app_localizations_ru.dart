// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Harmoney VPN';

  @override
  String get splashSubtitle => 'Создан для безопасного доступа в интернет,\nразработан для всех, везде';

  @override
  String get connect => 'Подключить';

  @override
  String get disconnect => 'Отключить';

  @override
  String get connected => 'Подключено';

  @override
  String get disconnected => 'Отключено';

  @override
  String get connecting => 'Подключение';

  @override
  String connectingVia(String groupName) {
    return 'ПОДКЛЮЧЕНИЕ ЧЕРЕЗ $groupName';
  }

  @override
  String get switchingMethod => 'ПЕРЕКЛЮЧЕНИЕ МЕТОДА';

  @override
  String get speedTest => 'Тест скорости';

  @override
  String get download => 'ЗАГРУЗКА';

  @override
  String get upload => 'ВЫГРУЗКА';

  @override
  String get ping => 'ПИНГ';

  @override
  String get latency => 'ЗАДЕРЖКА';

  @override
  String get jitter => 'ДЖИТТЕР';

  @override
  String get packetLoss => 'ПОТЕРЯ ПАКЕТОВ';

  @override
  String get tapHere => 'НАЖМИТЕ ЗДЕСЬ';

  @override
  String get settings => 'Настройки';

  @override
  String get introduction => 'Введение';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsAndConditions => 'Условия использования';

  @override
  String get ourWebsite => 'Наш веб-сайт';

  @override
  String get marketplace => 'Магазин';

  @override
  String get telegramBot => 'Телеграм-бот';

  @override
  String get sourceCode => 'Исходный код';

  @override
  String get openSourceLicenses => 'Лицензии с открытым исходным кодом';

  @override
  String get betaCommunity => 'Бета-сообщество';

  @override
  String get close => 'Закрыть';

  @override
  String get copyLogs => 'Копировать логи';

  @override
  String get logsCopied => 'Логи скопированы в буфер обмена';

  @override
  String get appLogs => 'Логи приложения';

  @override
  String get autoRefresh => 'Автообновление';

  @override
  String get clear => 'Очистить';

  @override
  String get quickMenu => 'Быстрое меню';

  @override
  String get noInternet => 'Нет интернета';

  @override
  String get error => 'Ошибка';

  @override
  String get loading => 'Загрузка';

  @override
  String get analyzing => 'Анализ';

  @override
  String get mbps => 'Мбит/с';

  @override
  String get ms => 'мс';

  @override
  String get language => 'Язык';

  @override
  String get tips => 'СОВЕТЫ';

  @override
  String get english => 'English (Английский)';

  @override
  String get chinese => '中文 (Китайский)';

  @override
  String get gotIt => 'Понятно';

  @override
  String get learnMore => 'УЗНАТЬ БОЛЬШЕ';

  @override
  String get harmoneyGoal => 'Цель Harmoney — обеспечить безопасный доступ к общедоступной информации и предоставить бесплатный просмотр.';

  @override
  String get statusIsChilling => 'отдыхает.';

  @override
  String get statusIs => 'это';

  @override
  String get statusFailed => 'не удалось.';

  @override
  String get statusHas => 'имеет';

  @override
  String get statusIsReturning => 'возвращается';

  @override
  String get statusToStandbyMode => 'в режим ожидания.';

  @override
  String get statusPluggingIn => 'подключение ...';

  @override
  String get statusPoweredUp => 'включен';

  @override
  String get statusDoingScience => 'выполняется работа ...';

  @override
  String get statusExitedMatrix => 'вышел из матрицы';

  @override
  String get statusSorry => 'нам очень жаль :(';

  @override
  String get statusConnectAlready => 'Подключиться сейчас';

  @override
  String get statusTestingSpeed => 'тестирование скорости ...';

  @override
  String get statusIsReady => 'готов';

  @override
  String get statusIsInTrouble => 'в беде.';

  @override
  String get statusDXcoreDown => 'DXcore недоступен.';

  @override
  String get statusToSpeedTest => 'к тесту скорости';

  @override
  String get statusYoursToShape => 'создан для вас';

  @override
  String get settingsConnectionMethod => 'МЕТОД ПОДКЛЮЧЕНИЯ';

  @override
  String get settingsEscapeMode => 'РЕЖИМ ОБХОДА';

  @override
  String get settingsDestination => 'НАЗНАЧЕНИЕ';

  @override
  String get settingsSplitTunnel => 'РАЗДЕЛЬНОЕ ТУННЕЛИРОВАНИЕ';

  @override
  String get settingsKillSwitch => 'АВАРИЙНОЕ ОТКЛЮЧЕНИЕ';

  @override
  String get settingsDeepScan => 'ГЛУБОКОЕ СКАНИРОВАНИЕ';

  @override
  String get settingsHealthCheck => 'ПРОВЕРКА ЗДОРОВЬЯ';

  @override
  String get settingsIncluded => 'ВКЛЮЧЕНО';

  @override
  String get settingsAtLeastOneCoreRequired => 'Должен оставаться включенным хотя бы один модуль';

  @override
  String get settingsResetToDefault => 'Сброс';

  @override
  String get offlineFlowlineMessage => 'Обновления Flowline приостановлены, так как используется автономная версия.';

  @override
  String get offlineFlowlineUndo => 'ОТМЕНИТЬ';

  @override
  String get updateAvailable => 'Доступно обновление';

  @override
  String get updateRequired => 'Требуется обновление';

  @override
  String get updateOptionalMessage => 'Чтобы получить максимум от приложения и насладиться последними улучшениями, пожалуйста, обновитесь до новейшей версии.';

  @override
  String get updateRequiredMessage => 'Для продолжения использования Harmoney, пожалуйста, обновитесь до последней версии. Это обновление включает критические улучшения и необходимо для работы приложения.';

  @override
  String get updateNow => 'Обновить сейчас';

  @override
  String get notNow => 'Не сейчас';

  @override
  String get updateMethods => 'Обновить методы';

  @override
  String get importConfig => 'Импорт конфигурации';

  @override
  String get synchronization => 'Синхронизация';

  @override
  String get settingsDonation => 'Пожертвование';

  @override
  String get settingsDonationDescription => 'Помогите нам разрушить стены цифровой цензуры и интернет-фильтрации.';

  @override
  String get authenticationRequired => 'Требуется аутентификация';

  @override
  String get premiumLoginDescription => 'Для доступа к вашим премиум-подпискам вам необходимо войти в систему или создать учетную запись на веб-сайте Harmoney.';

  @override
  String get email => 'Электронная почта';

  @override
  String get emailHint => 'example@domain.com';

  @override
  String get emailValidation => 'Пожалуйста, введите ваш адрес электронной почты';

  @override
  String get password => 'Пароль';

  @override
  String get passwordHint => 'Введите ваш пароль';

  @override
  String get passwordValidation => 'Пожалуйста, введите ваш пароль';

  @override
  String get passwordMinLength => 'Пароль должен содержать не менее 6 символов';

  @override
  String get login => 'Войти';

  @override
  String get noAccount => 'Нет учетной записи?';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get loginFailed => 'Ошибка входа. Проверьте свои учетные данные и попробуйте снова.';

  @override
  String get loginSuccess => 'Вход выполнен успешно!';

  @override
  String get code => 'Код';

  @override
  String get codeHint => 'Введите ваш код доступа';

  @override
  String get codeValidation => 'Пожалуйста, введите ваш код';

  @override
  String get premiumLoginByCodeDescription => 'Для доступа к вашим премиум-подпискам введите предоставленный вам код доступа.';

  @override
  String get havingTrouble => 'Возникли проблемы?';

  @override
  String get signedInAs => 'Вы в настоящее время вошли в систему с адресом электронной почты';

  @override
  String get premiumImportDescription => 'Если ваши премиум-подписки не могут быть загружены из-за ограничений интернета и вы не можете подключиться доступными методами, вы можете импортировать файл, полученный из Маркетплейса, в приложение.';

  @override
  String get planningToExit => 'Планируете выйти?';

  @override
  String get signOut => 'Выйти';

  @override
  String get signOutSuccess => 'Выход выполнен успешно!';

  @override
  String get settingsMarketplace => 'Маркетплейс';

  @override
  String get marketplaceDescription => 'Просмотрите безопасные конфигурации VPN от проверенных поставщиков.';

  @override
  String get loggedIn => 'ВОШЛИ В СИСТЕМУ';

  @override
  String get loginOrRegister => 'ВОЙТИ ИЛИ ЗАРЕГИСТРИРОВАТЬСЯ';

  @override
  String get loginByCode => 'Войти по коду';

  @override
  String get backToLoginByEmail => 'Вернуться к входу по электронной почте';

  @override
  String get connectionRequired => 'Требуется подключение';

  @override
  String get connectionRequiredDescription => 'Чтобы завершить безопасный процесс входа или регистрации, вы должны сначала установить соединение, используя один из доступных методов подключения.';

  @override
  String get inlineText_a5998db73b68af63 => 'Настройки сервера';

  @override
  String get inlineText_3305ac4300665f71 => 'Автоматическое сканирование этого устройства';

  @override
  String get inlineText_fa7af603d430b209 => 'Отмена';

  @override
  String get inlineText_9de2a0d933190a40 => 'Harmoney Pro';

  @override
  String get inlineText_9fd728c66c9a256b => 'Добавить';

  @override
  String get inlineText_8450d81a2ef331f0 => 'Не поддерживается на этой платформе.';

  @override
  String get inlineText_6f759aed280d8ae1 => 'Идентификатор оборудования сброшен до значения по умолчанию для сервера.';

  @override
  String get inlineText_10ae58fbb5984f6e => 'В Android и Linux используется выбранная подписка, но ядро ​​VPN может выбрать из нее другой узел.';

  @override
  String get inlineText_c01c4324f1fa14fc => 'Импорт…';

  @override
  String get inlineText_ef207787e1f5054a => 'Обход отдельных приложений не поддерживается на этой платформе.';

  @override
  String get inlineText_543264e2f45dd255 => 'Обход VPN';

  @override
  String get inlineText_034fc31b30e178f0 => 'VPN-протокол Firefox';

  @override
  String get inlineText_4fcf7e0d90445713 => 'Отключено: весь трафик проходит безопасно через зашифрованный VPN-туннель.';

  @override
  String get inlineText_272a96114c7af32f => 'Пользовательские правила обхода';

  @override
  String get inlineText_7b547a5ae60b2f38 => 'Firefox VPN';

  @override
  String get inlineText_4b42c738a9185fc5 => 'Точка доступа активна';

  @override
  String get inlineText_fa174cea0ac4357d => 'Сохранить настройку';

  @override
  String get inlineText_5474eef8d0f179c7 => 'Выполняется…';

  @override
  String get inlineText_e6f7f8ccc059e5c7 => 'Приложения не выбраны.';

  @override
  String get inlineText_df8748e19fc6ee2b => 'Отключение занимает больше времени, чем ожидалось. Вы можете попробовать еще раз.';

  @override
  String get inlineText_c0bd827e34b175ab => 'Блокировать доступ в Интернет';

  @override
  String get inlineText_7af2f7454f3b55aa => 'Обновить статус и квоту';

  @override
  String get inlineText_eea2745e2867a677 => 'Проверять';

  @override
  String get inlineText_88712c434b491bce => 'Требуется вход';

  @override
  String get inlineText_7d9eb7acb13e2462 => 'Закрыть';

  @override
  String get inlineText_46b5d935b82dd8e0 => 'Выберите службу подключения';

  @override
  String get inlineText_8035283793ddc0b5 => 'Запросить последний сеанс и квоту трафика';

  @override
  String get inlineText_64a985f51e17518b => 'Никаких пользовательских правил обхода.';

  @override
  String get inlineText_90e0e260530759ce => 'Только хост-компьютер';

  @override
  String get inlineText_fa1cf54705b7a6ea => 'Создать идентификатор оборудования устройства';

  @override
  String get inlineText_8693a5d72c6b23fa => 'Поделитесь безопасным зашифрованным туннелем с телефонами и планшетами';

  @override
  String get inlineText_0d21bd52022ca7f7 => 'Онлайн';

  @override
  String get inlineText_7d096ae1ecf2a8cc => 'Обход';

  @override
  String get inlineText_2fc9fc3695f14892 => 'Отключить оптимизацию';

  @override
  String get inlineText_6405b0129cf5a714 => 'Сгенерированный окончательный идентификатор (SHA-256):';

  @override
  String get inlineText_5f65ccdf701bd499 => 'Сохранить настройки';

  @override
  String get inlineText_c90fdfab474bdd3e => 'Войдите в аккаунт';

  @override
  String get inlineText_1c114a72bff7ecbc => 'Ремонт ИКС';

  @override
  String get inlineText_c3a6d1c87fa8d4bb => 'История испытаний скорости';

  @override
  String get inlineText_4d9bfca28655ee45 => 'Загрузка сеанса:';

  @override
  String get inlineText_1a095c79818885e4 => 'Запустить гостя';

  @override
  String get inlineText_d18f4156fea49644 => 'Проверка учётной записи…';

  @override
  String get inlineText_ac7c949f1211b781 => 'Неактивный';

  @override
  String get inlineText_9c1ff072196e2d26 => 'Готовы выполнять оперативную маршрутизацию и аудит безопасности.';

  @override
  String get inlineText_df578dfdf0dafa9a => 'Никаких тестов скорости пока не зарегистрировано.';

  @override
  String get inlineText_5d6529256c6c68f0 => 'Запустить прямой запуск';

  @override
  String get inlineText_23d5d93cf5f11e17 => 'Неограниченная квота';

  @override
  String get inlineText_1228cd974a4510cf => 'Экспорт серверов';

  @override
  String get inlineText_0323bbb0e3e24d50 => 'Разрешить IPv6';

  @override
  String get inlineText_58e27854800bc94b => 'Сеть не заблокирована: аварийный переключатель, маршруты и интерфейсы XFRM восстановлены в нормальном состоянии.';

  @override
  String get inlineText_d71035f8d7c85940 => 'Параметры защищенной точки доступа';

  @override
  String get inlineText_14bd9f9fb68a5859 => 'Выберите провайдера VPN';

  @override
  String get inlineText_cbca739d8ccd07e1 => 'Проверьте интерфейс XFRM, таблицу 220, правила IP и проверьте безопасность живого соединения.';

  @override
  String get inlineText_d0527e4b3d658351 => 'Выход из системы';

  @override
  String get inlineText_f7fa281a488a9a0d => '50 ГБ';

  @override
  String get inlineText_a38c71d45d21c4ab => 'Уведомить только';

  @override
  String get inlineText_b8352b44a588721c => 'Язык приложения';

  @override
  String get inlineText_e55142a1acfd8059 => 'Имя пользователя';

  @override
  String get inlineText_f2b10ce04701badc => 'Загружать приложения';

  @override
  String get inlineText_b1fe69e5cd48a270 => '-- РС';

  @override
  String get inlineText_989961ec7fc20bdd => 'Обход приложения Android применяется после повторного подключения VPN.';

  @override
  String get inlineText_039b675cbfc3719c => 'HTTP/2 ПОДКЛЮЧИТЬ';

  @override
  String get inlineText_7366b74aba11b666 => 'Вывод консоли скопирован в буфер обмена.';

  @override
  String get inlineText_0173658e5af8698d => 'Пакет поддержки экспортирован и скопирован в буфер обмена.';

  @override
  String get inlineText_9f658c229a11bef6 => 'Настраивает Windows ICS для адаптера VPN, когда мобильная точка доступа активна. Приложение проверяет привязку ICS; клиентский интернет-трафик по-прежнему нуждается в сквозной проверке.';

  @override
  String get inlineText_73997b80ca90ece7 => 'В настоящее время к точке доступа нет подключенных устройств. Политика';

  @override
  String get inlineText_ebf5f31bd3fa8cf4 => 'Отменить тест';

  @override
  String get inlineText_4bfa799fae21b467 => 'Аналитика трафика';

  @override
  String get inlineText_b28b26cf1cc18caf => 'Более спокойная связь. Более яркий мир.';

  @override
  String get inlineText_ed95556c5c93ded1 => 'Обход страны и приложения';

  @override
  String get inlineText_4cf9134d1c9ed485 => 'Вывод профилей подключения';

  @override
  String get inlineText_2a78025de6aae5e7 => 'Выбирать';

  @override
  String get inlineText_cbbea9d808ebfe70 => 'Surfshark';

  @override
  String get inlineText_88921e28030e4255 => 'Сервисный пароль/закрытый ключ';

  @override
  String get inlineText_39c3183ee0cbb997 => 'Правила расширенной политики не настроены.';

  @override
  String get inlineText_6cb8a5b3137a00c3 => 'Диапазоны IP-адресов выбранных стран обходят VPN. Переподключитесь после изменения правил. Правила только для домена требуют маршрутизации с учетом DNS.';

  @override
  String get inlineText_8bb1de2dfce6294f => 'Подключение…';

  @override
  String get inlineText_22965568d22a14ee => 'Подключено';

  @override
  String get inlineText_e7e2af717bdfb964 => 'Авто (резервный режим)';

  @override
  String get inlineText_42b5bc901ede1799 => '100 ГБ';

  @override
  String get inlineText_24ef681c569b5c42 => 'Системные приложения';

  @override
  String get inlineText_3e2421c56094293c => 'Таблица маршрутов и проверка XFRM';

  @override
  String get inlineText_5d7cd082fc9987e9 => 'Принудительное VPN Зашифрованное';

  @override
  String get inlineText_1159717463f1ebc3 => 'Имя пользователя службы/идентификатор ключа';

  @override
  String get inlineText_0e76960093379060 => 'История';

  @override
  String get inlineText_cb0bf46bf1e385db => 'Импортировать ZIP-файл';

  @override
  String get inlineText_2da236423b3b5ad5 => 'Крышка Always On и Lockdown поддерживает соединения VPN. Политики DNS и IPv6 применяются активным туннелем.';

  @override
  String get inlineText_50829e8639527356 => 'Добавить приложение (.exe)';

  @override
  String get inlineText_f6f39fe075ffa5de => 'Добавьте приложение перед включением обхода приложений.';

  @override
  String get inlineText_5a99f6fa7e98657a => 'Сканировать QR-код';

  @override
  String get inlineText_c4b6bf5634f8ce91 => 'Объясните, почему пункт назначения маршрутизируется через VPN или Direct ISP с сопоставлением приоритетов правил.';

  @override
  String get inlineText_cf0883343f4abef7 => 'Протокол';

  @override
  String get inlineText_adec3733feabdc2d => 'Файлы были успешно извлечены.';

  @override
  String get inlineText_0c567745c63c57bc => 'Android поддерживает обход CIDR IPv4 и IPv6. Повторно подключите VPN после изменения этих маршрутов; Обход приложения также вступает в силу после повторного подключения.';

  @override
  String get inlineText_cb0544450e1be874 => 'Выполняется проверка…';

  @override
  String get inlineText_9e19b3ae1edc6135 => 'Блокировка Android активна';

  @override
  String get inlineText_0acb9208ef119b21 => 'Открыть мобильную точку доступа';

  @override
  String get inlineText_61118b57b609e8fd => 'Управление подключением, безопасностью и внешним видом';

  @override
  String get inlineText_ed077f3d8125d60d => 'Открыть';

  @override
  String get inlineText_bbf3d191d555c872 => 'Места и маршруты';

  @override
  String get inlineText_c01d52ac9ed5701a => 'Ошибка подключения Harmoney Pro';

  @override
  String get inlineText_25a76b0a4ba5c39d => 'Безопасное применение и LKG';

  @override
  String get inlineText_967549497036d513 => 'Отменить выбор всех';

  @override
  String get inlineText_72a47f8e322a40de => 'Панель защиты';

  @override
  String get inlineText_2398cc05005cca7f => 'Автономный кэш готов';

  @override
  String get inlineText_469f27ad0a12c557 => 'Этот идентификатор используется в качестве аппаратного отпечатка (Hardware Device ID) для аутентификации устройства на сервере. Вы можете изменить значения или получить авто:';

  @override
  String get inlineText_783547972fe4ca08 => 'IKEv2';

  @override
  String get inlineText_03f15c48644862ae => 'Маршрут к точке доступа по умолчанию';

  @override
  String get inlineText_bd5a05ddab828e6d => 'Запустить гостевую Wi-Fi';

  @override
  String get inlineText_4968fc7fef5ea571 => 'Оставшийся трафик:';

  @override
  String get inlineText_52a0bc5a1f46b6a1 => 'Firefox Аккаунт';

  @override
  String get inlineText_bb93f3cc26e28600 => 'Временный изолированный гостевой Wi-Fi с автоматическим сроком действия и изоляцией подсети.';

  @override
  String get inlineText_b361f42b64c263d8 => 'Проверка защищённого хранилища учётных данных…';

  @override
  String get inlineText_7d037fcb85b5a1eb => 'Прямой (обход VPN)';

  @override
  String get inlineText_e65731cec92db7d5 => 'Операция VPN уже запущена. Пожалуйста, подождите, пока его статус обновится.';

  @override
  String get inlineText_f24d839a275e6eaa => 'Включить общий доступ к точкам доступа (ICS)';

  @override
  String get inlineText_03a71a235bfb6b30 => 'Вход прошел успешно, список серверов обновлен.';

  @override
  String get inlineText_52933373144828ee => 'Адрес электронной почты/пользователь учетной записи Firefox';

  @override
  String get inlineText_d86322c4ceb937de => 'Страновые диапазоны IPv4 обходят VPN после повторного подключения. Обход приложения использует физический интерфейс Windows и требует службы Harmoney.';

  @override
  String get inlineText_77f0b86ebfb47aa6 => 'Идентификатор оборудования устройства успешно установлен.';

  @override
  String get inlineText_35d7442440a55ab9 => 'Чтобы Android не отключал VPN-соединение в фоновом режиме, отключите оптимизацию заряда батареи для этого приложения.';

  @override
  String get inlineText_3da7d703985421ec => 'Firefox разрешение данных';

  @override
  String get inlineText_316f766fb0bc3a72 => 'Управление учетной записью Firefox VPN';

  @override
  String get inlineText_69b95013a9101213 => 'Правила расширенной политики';

  @override
  String get inlineText_9d0c59a66cf45b32 => 'Привязка VPN к точке доступа ICS проверена.';

  @override
  String get inlineText_7ae00a283ea9b728 => 'Срок действия сессии истек';

  @override
  String get inlineText_0dd786510199ca80 => 'Настройки подключения службы';

  @override
  String get inlineText_708e318e0225bc88 => 'Остановить гостя';

  @override
  String get inlineText_ad4b77a68783ec24 => 'Продолжительность сеанса';

  @override
  String get inlineText_25dcc872936aab98 => 'Учетные данные учетной записи Firefox отправляются непосредственно в Mozilla локальным помощником Windows. Пароль не сохраняется; локально хранятся только токены учетной записи, необходимые для будущих подключений.';

  @override
  String get inlineText_219113c4bbe2e98c => 'Обход отдельных приложений Windows маршрутизирует выбранные приложения напрямую через физический адаптер, независимо от активного протокола VPN. Требуется поддержка сборки Windows и привилегированный сервис Harmoney.';

  @override
  String get inlineText_21e3324fcec20e63 => '0 ГБ (Выкл.)';

  @override
  String get inlineText_20636a0c41a3f954 => 'Расширенная маршрутизация и защита';

  @override
  String get inlineText_dc8bf418d2bb68a6 => 'Безопасный VPN DNS';

  @override
  String get inlineText_a0b16ccf9021fc82 => 'Живой активный';

  @override
  String get inlineText_abff5572a370fab7 => 'В очереди…';

  @override
  String get inlineText_b666d8596482e260 => 'Xray напрямую маршрутизирует выбранные диапазоны IPv4/IPv6 и встроенный список иранских доменов. После изменения правил подключитесь заново.';

  @override
  String get inlineText_df74ccb45d0e395d => 'Направляйте определенные пункты назначения через Direct, Force VPN или Block.';

  @override
  String get inlineText_1509f561f2416598 => 'Сохранить';

  @override
  String get inlineText_7122ed800123d8e7 => 'Принудительная точка доступа VPN DNS';

  @override
  String get inlineText_6b97c41651da98ce => 'Автоматически получать с системного оборудования';

  @override
  String get inlineText_6f98676a0a7b4953 => 'Служба частного подключения';

  @override
  String get inlineText_0fb48c86db0c3f8f => 'Блокировать соединения без VPN';

  @override
  String get inlineText_2427a4a9d7993571 => 'Журналы Talker';

  @override
  String get inlineText_da223b83cdddd9db => 'Запустить Hotspot Doctor';

  @override
  String get inlineText_a899ea0cfb536e60 => 'Обновите токены сеанса или смените учетную запись.';

  @override
  String get inlineText_70e3135873ca12f3 => 'Войти для загрузки серверов';

  @override
  String get inlineText_98e33b0f3104fcf1 => 'Приложения';

  @override
  String get inlineText_c6c2daab1f7d2fe5 => 'Скорость в режиме реального времени';

  @override
  String get inlineText_81e9f4e64a840785 => 'Добавьте хотя бы одно приложение, чтобы включить эту функцию.';

  @override
  String get inlineText_942087cc2d41e013 => 'Повторить попытку';

  @override
  String get inlineText_3fb9aa9bdbb56bb6 => 'Создать новый список';

  @override
  String get inlineText_47e52e5e678a2248 => 'Журналы скопированы в буфер обмена (секреты отредактированы).';

  @override
  String get inlineText_cf406ea597d7a11b => 'Вывод диагностического терминала';

  @override
  String get inlineText_5c8925f30317c4ae => 'Блокировать IPv6 (Защита от утечек)';

  @override
  String get inlineText_d69fa3897fde1fd7 => 'Для рукопожатий необходимы имя пользователя и пароль службы.';

  @override
  String get inlineText_f98a2522000fbae8 => '200 ГБ';

  @override
  String get inlineText_30dc86f4e57e4278 => 'Применить к настройкам';

  @override
  String get inlineText_14eee0b522b0a07f => 'Блокировка всех утечек Интернета при неожиданном отключении VPN';

  @override
  String get inlineText_b813ec3c634e571c => 'Направляйте выбранные приложения или сетевые подсети за пределы VPN.';

  @override
  String get inlineText_d21cca3751709e6f => 'Аппаратное шифрование: учетные данные шифруются в хранилище платформы.';

  @override
  String get inlineText_ff4fcf35e586d0ca => 'Кандидаты на конечные точки';

  @override
  String get inlineText_85455433f68a0eea => 'Объяснение маршрута';

  @override
  String get inlineText_e6e283499c38fe99 => 'Протестировать все';

  @override
  String get inlineText_df8bb62c5262aace => 'Открыть папку';

  @override
  String get inlineText_ca4ce07eeab21f24 => 'Личные подписки';

  @override
  String get inlineText_ccccab7c5d91fcc1 => 'Release Highlights';

  @override
  String get inlineText_fbfd8ce759281a7c => 'Повторный вход';

  @override
  String get inlineText_48a39c950b733f9d => 'Восстановить маршрутизацию горячих точек';

  @override
  String get inlineText_1f914c4386c0676e => 'ПОДКЛЮЧЕНО';

  @override
  String get inlineText_fd67fb8b214d0251 => 'Harmoney Update Available';

  @override
  String get inlineText_5e0104e1d0dd6cc2 => 'Начать тест скорости';

  @override
  String get inlineText_9225ef77a358de37 => 'Крышки постоянного включения и блокировки Firefox, WireGuard, IKEv2 и OpenVPN. Политики DNS и IPv6 применяются каждым активным профилем туннеля.';

  @override
  String get inlineText_04b476ffe80f996f => 'Включить обход отдельных приложений';

  @override
  String get inlineText_e0b8edec85fbec56 => 'Конфигурация сервера (исходный код по умолчанию — только в режиме отладки)';

  @override
  String get inlineText_a47e46554344d955 => 'для упрощения подключения из командной строки (пароль хранится в виде открытого текста)';

  @override
  String get inlineText_23be2e66d9c671b4 => 'Загрузите установленные приложения, чтобы настроить обход каждого приложения.';

  @override
  String get inlineText_60cc8000034bbcc6 => 'Введите значения и вручную создайте';

  @override
  String get inlineText_14ea6d8e1758ce8f => 'Войти Harmoney Pro';

  @override
  String get inlineText_b764cdc0eab71374 => 'Неизвестный';

  @override
  String get inlineText_55b98eedd56ac65c => 'Больше протоколов и вариантов подключения';

  @override
  String get inlineText_aa669b285cc133bf => 'Циско';

  @override
  String get inlineText_5e414ee0c5da2dde => 'Пинговать все';

  @override
  String get inlineText_e281f68dc29144b2 => 'Добавьте URL-адрес подписки HTTP или HTTPS. Ссылки надежно хранятся на этом устройстве.';

  @override
  String get inlineText_90f46423c0074765 => 'Загрузка сессии:';

  @override
  String get inlineText_36230e6a755f25c0 => 'Выбранные приложения используют физическую сеть напрямую. Другие приложения продолжают использовать VPN.';

  @override
  String get inlineText_e0166a69e70a0063 => 'Включено для Harmoney';

  @override
  String get inlineText_68eda25757c8e549 => 'Сохраненные подписки';

  @override
  String get inlineText_639a40e82b9a96f0 => 'Соединение';

  @override
  String get inlineText_2a5c4cf3cff579c9 => 'Выберите приложения для обхода VPN-туннеля и прямого подключения к Интернету.';

  @override
  String get inlineText_229b05d20a6d2706 => 'VPN-аккаунт Firefox';

  @override
  String get inlineText_e1f42d830cee8336 => 'Служба подключения';

  @override
  String get inlineText_69cd3590300a68c6 => 'Проверить статус';

  @override
  String get inlineText_79f4939f31f74600 => 'Android Защита';

  @override
  String get inlineText_e9f61c5ca23f266f => 'События оперативного подключения от всех провайдеров и протоколов';

  @override
  String get inlineText_a0610c3d3b91cb4f => 'Harmoney Smart';

  @override
  String get inlineText_c0671aa2f2dd814a => 'Download & Update';

  @override
  String get inlineText_1a938f00d128e40c => 'Живая скорость и трафик';

  @override
  String get inlineText_74ca300a6cadb68a => 'Точка доступа IPv6';

  @override
  String get inlineText_c2ed1ff176791192 => 'Политика маршрутизации:';

  @override
  String get inlineText_b8b960fef99adfb1 => 'Требуется вход в Harmoney Pro';

  @override
  String get inlineText_a23e527773f02a67 => 'Harmoney';

  @override
  String get inlineText_2067e249c2b1e5de => 'Квота превышена. Действие:';

  @override
  String get inlineText_3b61e4e936523550 => 'Объясните политику';

  @override
  String get inlineText_bd8256cb9d1b917f => 'Правила применяются к активному маршруту VPN. Пересылка UDP ещё не завершена; приложениям, которым нужен UDP, может быть недоступен полный обход VPN.';

  @override
  String get inlineText_664479f12348ca20 => 'Начать извлечение';

  @override
  String get inlineText_2fd1a96a8b9a93c0 => 'Учетная запись службы Surfshark';

  @override
  String get inlineText_37d1bd40cc9b7ba7 => 'Использует собственную маршрутизацию каждого процесса Windows для отправки выбранных приложений непосредственно через физический сетевой адаптер. Требуется совместимая сборка Windows и служба Harmoney VPN.';

  @override
  String get inlineText_e2419bb6585fdf13 => 'Страны назначения обходят VPN напрямую через интернет-провайдера; другой трафик остается внутри VPN.';

  @override
  String get inlineText_566bd7ec6c74731b => 'В системе не обнаружен активный интерфейс точки доступа.';

  @override
  String get inlineText_1d653fc4503ec979 => 'The update will download and install directly inside Harmoney.';

  @override
  String get inlineText_9e4a7faff61f59aa => 'Профиль оборудования: Dell Latitude 7210 и Intel/Cellular LTE';

  @override
  String get inlineText_515c0e6425c1c144 => 'Правил CIDR пока нет.';

  @override
  String get inlineText_60c5a84642b61c53 => 'Включите блокировку в настройках Android VPN.';

  @override
  String get inlineText_cb222670e743b957 => 'Пароль';

  @override
  String get inlineText_d1ad5bbe561caba5 => 'Назначение блока';

  @override
  String get inlineText_54b8e0c0c268c154 => 'Копировать отчет';

  @override
  String get inlineText_7539a050c6489953 => 'Ссылка для скачивания Harmoney Pro пока недоступна.';

  @override
  String get inlineText_4759498ac2a719c6 => 'Создать';

  @override
  String get inlineText_089899b425d4bcda => 'Добавить подписку';

  @override
  String get inlineText_838c8e30c9aeac8a => 'Гостевая точка доступа';

  @override
  String get inlineText_475e433587200d99 => 'Обеспечить доступность внутренних услуг и банковских услуг при отключении VPN';

  @override
  String get inlineText_0b4666b1dcc9f6f9 => 'Включить разделенное туннелирование';

  @override
  String get inlineText_cb2b6a572a8588d8 => 'Отключение…';

  @override
  String get inlineText_fb94fc702eb62ab7 => 'Скачать Harmoney Pro';

  @override
  String get inlineText_ad7b66a913a46286 => 'ОТКЛЮЧЕНИЕ';

  @override
  String get inlineText_74a883a037bc227f => 'Настройки';

  @override
  String get inlineText_6c2a96757bb1ab31 => 'Настройки API';

  @override
  String get inlineText_a63b3bb0ad3689a0 => 'Время предыдущей операции VPN истекло. Вы можете попробовать еще раз.';

  @override
  String get inlineText_b11e1aa7421b52e2 => 'Тест маршрута';

  @override
  String get inlineText_73b6e48a1b552d11 => 'Later';

  @override
  String get inlineText_c1c1009d3f37ec05 => 'Update';

  @override
  String get inlineText_fa488105cb65db88 => 'Сеанс безопасности истек; пожалуйста, войдите еще раз, чтобы использовать серверы.';

  @override
  String get inlineText_4bd0e4ba0e817d11 => 'Безлимит (Выкл.)';

  @override
  String get inlineText_690dbe9dc0993c42 => 'Недавний';

  @override
  String get inlineText_005ef7725a64c7ed => 'New Version Available';

  @override
  String get inlineText_92723a5ff9689c3d => 'Маршруты из конфигураций Xray, WARP и MASQUE. Соединение отображается после проверки трафика.';

  @override
  String get inlineText_c5842271209f9ff7 => 'Покрытие протокола';

  @override
  String get inlineText_1fc9a387654d410f => 'Выбрать все';

  @override
  String get inlineText_b0e17c2810653b13 => 'Install Now';

  @override
  String get inlineText_5aa9ef74c967df76 => 'Пользовательские списки местоположений';

  @override
  String get inlineText_ad208643ab98407d => 'Настройки раздачи точки доступа сохранены.';

  @override
  String get inlineText_5e1133591cfeb5b0 => 'Только клиенты Hotspot';

  @override
  String get inlineText_d636391ee4236395 => 'Подходящих событий пока нет. Запустите соединение VPN для сбора журналов.';

  @override
  String get inlineText_ebbe7ab0b58e10be => 'Сканировать QR-код подписки';

  @override
  String get inlineText_092283a13b34e9ed => 'Показать серверы';

  @override
  String get inlineText_e548577f0fd46659 => 'Учетные данные учетной записи Firefox отправляются непосредственно в Mozilla собственным движком Android. Зашифрованные токены никогда не попадают в хранилище Flutter.';

  @override
  String get inlineText_a836bff92bbc5af0 => 'Повторно войдите в учетную запись';

  @override
  String get inlineText_50688e3917acdfec => 'Экспортируйте выбранный список серверов в файлы JSON и TXT.';

  @override
  String get inlineText_9b13e877e4aa90a7 => 'Вошёл в систему';

  @override
  String get inlineText_854d3eab6d8d5d33 => 'Вход и загрузка серверов';

  @override
  String get inlineText_c0d31ce834b82a7e => 'Нет любимых серверов.';

  @override
  String get inlineText_4511036a54304f80 => 'Update Download Complete';

  @override
  String get inlineText_76b23f49c19a08d8 => 'Перенаправить все запросы устройства DNS на Surfshark DNS.';

  @override
  String get inlineText_5a23444828db654a => 'Управлять';

  @override
  String get inlineText_5fedacfb015245b7 => 'Журналы активных подключений (поток)';

  @override
  String get inlineText_7446eabf9cf13622 => 'IPv6 защита от утечек';

  @override
  String get inlineText_2de8796023cbb4c7 => 'Нет ограничений';

  @override
  String get inlineText_7a7832e87a88a9c7 => 'WFP применяет правила независимо от IKEv2, WireGuard, OpenVPN и Xray. Ретрансляция UDP еще не завершена, поэтому приложения, требующие UDP, не будут полностью обойдены.';

  @override
  String get inlineText_a0e1a519f04a9b3e => 'ПОДКЛЮЧЕНИЕ';

  @override
  String get inlineText_289afa804e34a45f => 'Разрешить трафик Ирана во время блокировки';

  @override
  String get inlineText_ce13fbfce966190e => 'Подписки пока не добавлены.';

  @override
  String get inlineText_893e490d64407b8e => 'Информация о квотах недоступна.';

  @override
  String get inlineText_9b89006aec802e94 => 'Журналы в реальном времени';

  @override
  String get inlineText_630c2f1c0ee1b8d7 => 'АКТИВНЫЙ';

  @override
  String get inlineText_92340695899bd2d8 => 'Активный';

  @override
  String get inlineText_203229774cceb5f3 => 'Управление учетной записью';

  @override
  String get inlineText_bf6ccf81398eed34 => 'Добавить политику';

  @override
  String get inlineText_a9884f2d7e028e02 => 'Импортированные профили не найдены.\\nИмпортируйте ZIP-архив из ручной настройки Surfshark.';

  @override
  String get inlineText_0c16e4802957bf2a => 'Update Interrupted';

  @override
  String get inlineText_94f105a3d269670f => 'Выберите местоположение или используйте самый быстрый сервер';

  @override
  String get inlineText_472590ae974d4c1f => 'Поставщик';

  @override
  String get inlineText_5541de9515522b98 => 'ОТКЛЮЧЕНО';

  @override
  String get inlineText_0e223795fafb578e => 'Настройки защиты применяются Android VpnService и вступают в силу после повторного подключения.';

  @override
  String get inlineText_bfd402b2f6f38125 => 'Войти';

  @override
  String get inlineText_970c6a41454fa6ee => 'Общее состояние туннеля';

  @override
  String get inlineText_f4c3265a274f6fa8 => 'Направьте IPv6 через поддерживаемые туннели; переподключитесь, чтобы применить';

  @override
  String get inlineText_ecf1d7c868ee46fc => 'Mbps';

  @override
  String get inlineText_f9f60b474c0c751b => 'Запустить гостевую точку доступа';

  @override
  String get inlineText_a840a9de3127ef53 => 'FireTunnel выполняет аутентификацию с помощью учетных записей Firefox. Учетные данные отправляются только встроенному помощнику, изолированному от корня; токены никогда не попадают в хранилище Flutter.';

  @override
  String get inlineText_dcbf414d58c417be => 'Аварийный останов';

  @override
  String get inlineText_4f5845ea70794fc8 => 'Ядро антицензуры Harmoney';

  @override
  String get inlineText_0234c7f3ac8b5b71 => 'Включить обход приложений';

  @override
  String get inlineText_24b8d9733417f7f2 => 'Создание защищённого туннеля…';

  @override
  String get inlineText_ec963ffc911b8401 => 'Проверка…';

  @override
  String get inlineText_c46c2996102a4b2c => 'Зашифрованный туннель проверен на отсутствие утечки пакетов.';

  @override
  String get inlineText_c0bf75bd78bf9572 => 'Изменять';

  @override
  String get inlineText_bcc0bcc9140b0c97 => 'Войти';

  @override
  String get inlineText_e7977ed18b1df209 => 'Обход каждого приложения';

  @override
  String get inlineText_0e91610117029a62 => 'Обновление';

  @override
  String get inlineText_6defafa2caa65304 => 'Настроить';

  @override
  String get inlineText_651f94aafffed603 => 'Запрос на отключение ещё обрабатывается…';

  @override
  String get inlineText_8b9d3de8ae00c89c => 'Выполняется вход…';

  @override
  String get inlineText_58b2c361864f4c09 => 'Всегда включен VPN';

  @override
  String get inlineText_8aa2064e8f385ad3 => 'Учетные данные и ключи службы';

  @override
  String get inlineText_7bcc95e0b5bd34c6 => 'Обход VPN для каждого приложения';

  @override
  String get inlineText_be6ee118f6ce86a8 => 'Downloading Update...';

  @override
  String get inlineText_67865eaee364dcbe => 'Пропускайте HTTPS-трафик через TCP/TLS для согласованной фильтрации.';

  @override
  String get inlineText_a52ace420f2175d0 => 'Все';

  @override
  String get inlineText_2eb0c5a3ce65868c => 'Живая пропускная способность, учет данных и квоты';

  @override
  String get inlineText_54386d5a6b84b6e8 => 'Оптимизация заряда батареи активна (режим ожидания)';

  @override
  String get inlineText_d0e13ceb47c44a7f => 'Умная маршрутизация и личные подписки';

  @override
  String get inlineText_1924fc22b6e86d49 => 'Активный протокол Surfshark';

  @override
  String get inlineText_1eecb5c3f3e93223 => 'Повторное подключение VPN для применения маршрутов Android CIDR.';

  @override
  String get inlineText_0ef1d485c68962e3 => 'Сервер по умолчанию';

  @override
  String get inlineText_1e77e9d04f19d6d9 => 'Клиенты узла и точки доступа';

  @override
  String get inlineText_f5af9ab211b447cd => 'Отчет о скорости скопирован в буфер обмена!';

  @override
  String get inlineText_edb18cd663b5e4de => 'Блок QUIC (UDP 443)';

  @override
  String get inlineText_ea32ef00138d4d85 => 'Управление подключенными устройствами, квотами пропускной способности, гостевой Wi-Fi и политиками маршрутизации.';

  @override
  String get inlineText_46ff63176dfa61e2 => 'Принудительное VPN';

  @override
  String get inlineText_f6f75ce9317a16db => 'Применить квоту';

  @override
  String get inlineText_72fe71cb37d209d2 => 'Обновить статус';

  @override
  String get inlineText_56b598dee4ddc136 => 'САМЫЙ БЫСТРЫЙ ⚡';

  @override
  String get inlineText_19766ed6ccb2f4a3 => 'Отменить';

  @override
  String get inlineText_7a1f2a83aca9a081 => 'Избранное';

  @override
  String get inlineText_876662d1d94ad13b => 'Проверка в реальном времени';

  @override
  String get inlineText_bf26c2ac087da6ff => 'Обход';

  @override
  String get inlineText_dfe40efe921fe88e => 'Обновление…';

  @override
  String get inlineText_247ea0cd6733f4fc => 'Выполнена аварийная остановка: процессы завершены, а физическая сеть отключена.';

  @override
  String get inlineText_7207233f2b0688ac => 'Быстрое подключение';

  @override
  String get inlineText_3c4846f1083e22ec => 'Разделенное туннелирование';

  @override
  String get inlineText_ec93679622950c2c => 'Место хранения по умолчанию:';

  @override
  String get inlineText_a76e13b9839270eb => 'Восстановить';

  @override
  String get inlineText_a4738b604a205c2e => 'Check Updates';

  @override
  String get inlineText_c4b662bd95db40f1 => 'Удалить сохраненные учетные данные с этого устройства';

  @override
  String get inlineText_adde42042c5c3caa => 'Приостановить подключение устройства';

  @override
  String get inlineText_200bc33c838b6604 => 'Идентификатор сервера по умолчанию';

  @override
  String get inlineText_ea61bc15688d1e48 => 'Скопировано!';

  @override
  String get inlineText_d3ee5446e626ae8f => 'Сетевые подсети (CIDRs)';

  @override
  String get inlineText_1640ef1a61f9a5ee => 'Обновлены правила обхода DAT для стран. Переподключите VPN, чтобы применить.';

  @override
  String get inlineText_d403c686f6a10480 => 'Подключение';

  @override
  String get inlineText_351d257b580bc419 => 'Выберите желаемого поставщика сети VPN';

  @override
  String get inlineText_1b4154057e37a0ff => 'Войдите в Harmoney Pro';

  @override
  String get inlineText_ae4e9b1ef2aa3860 => 'Выберите протокол Surfshark.';

  @override
  String get inlineText_83b12c2216efb4fd => 'Прозрачный';

  @override
  String get inlineText_269f0582347dbdf6 => 'Рекомендуемые быстрые маршруты';

  @override
  String get inlineText_9918aaf803c54fcf => 'Выберите QR-изображение';

  @override
  String get inlineText_307e253c39bae652 => 'Проверка соединения';

  @override
  String get inlineText_337db382095ce88d => 'Перенаправить запросы устройства DNS через выбранный VPN.';

  @override
  String get inlineText_5bb6d1b367fc7674 => 'WireGuard';

  @override
  String get inlineText_e8696f00501ad45a => 'Импортированные профили не найдены.\nИмпортируйте ZIP-архив из раздела ручной настройки Surfshark.';

  @override
  String get inlineText_b0230c537ca88c85 => 'Пользовательские приложения';

  @override
  String get inlineText_e9d51941d0c1f37b => 'Общий доступ к точкам доступа VPN (Windows ICS)';

  @override
  String get inlineText_6bcc8512de553613 => 'Показать все серверы';

  @override
  String get inlineText_9d4be9539f27c657 => 'Пользовательские списки пока не созданы.';

  @override
  String get inlineText_782ec78be81185c6 => 'Токен/пароль FireTunnel';

  @override
  String get inlineText_8a76134e54b9cfac => 'ТРЕБУЕТСЯ КЛЮЧ';

  @override
  String get inlineText_75081b593d15cf6e => 'Неполноценный';

  @override
  String get inlineText_2e5f79bb94a8c40b => 'Checking...';

  @override
  String get inlineText_471354282a521dd1 => 'Новый пользовательский список';

  @override
  String get inlineText_c7a43600b2a6507c => 'Войти / Аккаунт';

  @override
  String get inlineText_a919cfce15c49685 => 'Режим блокировки (Kill Switch)';

  @override
  String get inlineText_dd9e7664f013c1e5 => 'Учетные данные зашифрованы в хранилище ключей привилегированной платформы.';

  @override
  String get inlineText_f50e254cf57f39fd => 'Уменьшить скорость до 128 Кбит/с';

  @override
  String get inlineText_4e1af7c74096cf0a => 'Операция не удалась';

  @override
  String get inlineText_43e3ece73ff8f4eb => 'remaining';

  @override
  String get inlineText_e94356112ce4c59c => 'Точка доступа и устройства';

  @override
  String get inlineText_313cbecb4dd35728 => 'Закрыть';

  @override
  String get inlineText_d6eafe8235910042 => 'Скачать';

  @override
  String get inlineText_06bacdb5d18b0261 => 'Заблокировать Интернет';

  @override
  String get inlineText_8200a83deae2141b => 'Добавить правило CIDR';

  @override
  String get inlineText_a429cd15905e58a5 => 'Установить квоту';

  @override
  String get inlineText_57c95945cb8fe988 => 'Учетные данные службы VPN надежно сохранены.';

  @override
  String get inlineText_4ff946afb073da91 => 'Управление профилями VPN';

  @override
  String get inlineText_9bf1e054ed4cbacb => 'Сохранение имени пользователя и пароля в текстовом файле';

  @override
  String get inlineText_6cb535909a7f3875 => 'Запустить полный аудит';

  @override
  String get inlineText_8fcbf6bb3bf0b5a0 => 'Сортировать по задержке';

  @override
  String get inlineText_45ee3e003650a75f => 'Добавить правило политики маршрутизации';

  @override
  String get inlineText_04b93833872cc896 => 'Запрошено отключение…';

  @override
  String get inlineText_ad3d9699142e5339 => 'Сохраняйте безопасно';

  @override
  String get inlineText_c63e407525237f8d => 'VPN Журналы отладки';

  @override
  String get inlineText_530692d19626e11a => 'Xray напрямую маршрутизирует выбранные диапазоны IPv4/IPv6 и связанный список иранских доменов. Внедрение маршрута Windows IKEv2 остается только для IPv4. Переподключитесь после изменения правил.';

  @override
  String get inlineText_7c147e122ed7eeac => 'OpenVPN';

  @override
  String get inlineText_e17b6227325e1a8d => 'Пригодность интеллектуальных услуг';

  @override
  String get inlineText_73bfa58718abc908 => 'Аудит пути туннеля, тесты на утечки, проверка задержки и телеметрия во время выполнения';

  @override
  String get inlineText_659e50811965fe84 => 'Ежемесячное пособие';

  @override
  String get inlineText_6a4c3a4483b04488 => 'Ping';

  @override
  String get inlineText_11a6767d5674c7e4 => 'Готово';

  @override
  String get inlineText_acfc5be785a9bb3d => 'Отключить';

  @override
  String get inlineText_c3812fc4acb861d5 => 'Remove';

  @override
  String get inlineText_fe4f5f9fd7be7d92 => 'Изоляция клиентов';

  @override
  String get inlineText_865e89de78d94c74 => 'Загрузить';

  @override
  String get inlineText_0004bf6db9f12d54 => 'Обновить правила страны';

  @override
  String get inlineText_3e695daee969126c => 'Package installer launched. Tap below if you need to relaunch.';

  @override
  String get inlineText_a8b3ef62feba073f => 'Серверы не найдены.';

  @override
  String get inlineText_9ef0f877893218f3 => 'Токен и аутентификация Firefox VPN';

  @override
  String get inlineText_23759997b3c59884 => 'НЕИЗВЕСТНЫЙ';

  @override
  String get inlineText_e3b78e09863c99ac => 'Восстановление точки доступа и диагностика';

  @override
  String get inlineText_48845bff334a50a5 => 'Dismiss';

  @override
  String get inlineText_54a0e8c17ebb21a1 => 'Ошибка';

  @override
  String get inlineText_c8fd5b73d111ee1d => 'от Harmoney';

  @override
  String get inlineText_44e1911932d93644 => 'Хармони Про Сервис';

  @override
  String get inlineText_f6be68de3c8d5e7d => 'Ежемесячная квота данных';

  @override
  String get inlineText_51452219a8542052 => 'Кандидаты на конечные точки не настроены.';

  @override
  String get inlineText_f493cd9c7ae396ec => 'Войдите, чтобы активировать туннель Firefox и просмотреть квоту данных.';

  @override
  String get inlineText_8e1b786c7913210c => 'Сохранить квоту';

  @override
  String get inlineText_efb52e7172b77731 => 'Тема';

  @override
  String get inlineText_2c2648394a4fe357 => 'Добавить разделенный туннель CIDR';

  @override
  String get inlineText_ff6d5def69d21f32 => 'Предотвратить прямое взаимодействие подключенных клиентов точки доступа. Политика';

  @override
  String get inlineText_532eaabd9574880d => 'Тест';

  @override
  String get inlineText_02a2c8aa276c0c36 => 'DNS с туннельным управлением; переподключитесь, чтобы подать заявку';

  @override
  String get inlineText_abaf4ed786bb9340 => 'Домены, адреса IPv4 или CIDRs, которые всегда обходят VPN';

  @override
  String get inlineText_49a2fc4df1b8bad5 => 'Лёгкий туннель Firefox VPN';

  @override
  String get inlineText_2faba03e2b8726a9 => 'Последний тест скорости:';

  @override
  String get inlineText_5bb4dc6f47d4c040 => 'СОЕДИНЯТЬ';

  @override
  String get inlineText_9d4ad0b61b2359e9 => 'Импортируйте ZIP-архив';

  @override
  String get inlineText_243a20f9ba6c2892 => 'При достижении этого лимита вы получите визуальные оповещения.';

  @override
  String get inlineText_d3ae19164d4f0f44 => 'Диагностика и работоспособность';

  @override
  String get inlineText_3dd7fcefed0e482c => 'Точка доступа неактивна';

  @override
  String get inlineAttribute_a4282e4b2298b90b => 'из';

  @override
  String get inlineAttribute_1a765360a12ba19c => 'Поиск стран…';

  @override
  String get inlineAttribute_74c8361a4a1ca4c4 => 'Действие маршрута';

  @override
  String get inlineAttribute_be6ee118f6ce86a8 => 'Downloading Update...';

  @override
  String get inlineAttribute_440488e7af1a1602 => 'Домен, IPv4 или CIDR';

  @override
  String get inlineAttribute_1d653fc4503ec979 => 'The update will download and install directly inside Harmoney.';

  @override
  String get inlineAttribute_372167bb30249862 => 'Квота данных (МБ, 0 = неограниченно)';

  @override
  String get inlineAttribute_4b329f46e3e4aa50 => 'Осталось';

  @override
  String get inlineAttribute_8d634757de9d475f => '✓ Проверено: все проверки пройдены (XFRM, таблица 220, трассировка HTTPS)';

  @override
  String get inlineAttribute_b9893538a61f89ed => 'Имя пользователя подписки';

  @override
  String get inlineAttribute_2c80752638d7bd54 => 'вставить';

  @override
  String get inlineAttribute_df3b5afaf2778138 => 'Домен или IP';

  @override
  String get inlineAttribute_1803685bb41d1d8d => 'URL-адрес подписки';

  @override
  String get inlineAttribute_09231cb8338a0158 => 'Целевой домен или CIDR (например, 1.1.1.1/32)';

  @override
  String get inlineAttribute_474276a023bed5d8 => 'Предпочтительное имя (необязательно)';

  @override
  String get inlineAttribute_69612b885a0aff86 => 'Популярный сервер';

  @override
  String get inlineAttribute_e7cf3ef4f17c3999 => 'Пароль';

  @override
  String get inlineAttribute_f3380f7b44bd70af => 'Вставить';

  @override
  String get inlineAttribute_ad0eae0c2cd935dc => 'Armoney';

  @override
  String get inlineAttribute_3c128b5436b6d704 => 'Обновить все';

  @override
  String get inlineAttribute_969ccbd3cf6300ec => 'Электронная почта';

  @override
  String get inlineAttribute_1b37568c4311efeb => 'Поиск по названию приложения или пакету';

  @override
  String get inlineAttribute_4524cd31be7128c2 => 'например. Осталось 192.168.1.0/24 или 10.0.0.1/32';

  @override
  String get inlineAttribute_6077b2acb8754468 => 'Включить конечную точку';

  @override
  String get inlineAttribute_b84364651ab4f422 => 'CIDR или IP';

  @override
  String get inlineAttribute_73b6e48a1b552d11 => 'Later';

  @override
  String get inlineAttribute_be420e2629f2ebfa => 'Код подтверждения электронной почты';

  @override
  String get inlineAttribute_c1c1009d3f37ec05 => 'Update';

  @override
  String get inlineAttribute_b29904a25f1802a7 => 'Продолжительность (минуты, 5–1440)';

  @override
  String get inlineAttribute_a4738b604a205c2e => 'Check Updates';

  @override
  String get inlineAttribute_428ffb88a815b9be => 'Очистить просмотр';

  @override
  String get inlineAttribute_6016fb957fe261cc => 'Обновить все';

  @override
  String get inlineAttribute_005ef7725a64c7ed => 'New Version Available';

  @override
  String get inlineAttribute_a1ab6eca52db1b3b => 'Тестовый сервер';

  @override
  String get inlineAttribute_4504b2c82bef3d20 => 'Копировать журналы';

  @override
  String get inlineAttribute_356c851e4ec59a3d => 'Настроить устройство';

  @override
  String get inlineAttribute_c2ef8dd2545d2b04 => 'Имя в списке (например, European Fast)';

  @override
  String get inlineAttribute_f69c34c2fc4b9667 => 'Избранный сервер';

  @override
  String get inlineAttribute_00ea6b3b42dfb4b5 => 'Персонализация и создание идентификатора оборудования вручную';

  @override
  String get inlineAttribute_b073f6c68ef87211 => 'Область действия';

  @override
  String get inlineAttribute_59ca629220a63ede => 'Удалить';

  @override
  String get inlineAttribute_47311af432a79c40 => 'Удалить профиль';

  @override
  String get inlineAttribute_80884fb559e05bd9 => 'Отключить конечную точку';

  @override
  String get inlineAttribute_b0e17c2810653b13 => 'Install Now';

  @override
  String get inlineAttribute_6769ff871d28e2ce => 'Закрыть вывод';

  @override
  String get inlineAttribute_01e8ee2044c91ec5 => '•••••••••••••••';

  @override
  String get inlineAttribute_cdf0cf9ecdfecba8 => 'Пользовательские списки';

  @override
  String get inlineAttribute_05eccbc907509b4b => 'Ограничение скорости (кбит/с, 0 = неограниченно)';

  @override
  String get inlineAttribute_d4e54f76384bf545 => 'Повторить попытку';

  @override
  String get inlineAttribute_d3a8a299660b14d0 => 'Очистить журналы';

  @override
  String get inlineAttribute_7a3517625d7f32a6 => 'Копировать выходные данные';

  @override
  String get inlineAttribute_96f681e1e0e80f53 => 'Фильтровать по провайдеру, протоколу, статусу или ошибке';

  @override
  String get inlineAttribute_4511036a54304f80 => 'Update Download Complete';

  @override
  String get inlineAttribute_2e5f79bb94a8c40b => 'Checking...';

  @override
  String get inlineAttribute_842d8e425ecb5b64 => '??';

  @override
  String get inlineAttribute_ce21ed09a64c529b => 'Обнаружена скопированная ссылка на подписку.';

  @override
  String get inlineAttribute_1e5a5a18ae04113a => 'Быстрое меню';

  @override
  String get inlineAttribute_c611981fab983bc6 => 'Политика';

  @override
  String get inlineAttribute_43e3ece73ff8f4eb => 'Осталось';

  @override
  String get inlineAttribute_a624a1e41ffdc6d6 => 'с тестового сервера';

  @override
  String get inlineAttribute_fb156130b17c4be3 => 'Параметры учетной записи';

  @override
  String get inlineAttribute_0e08705e56eb56d8 => 'Копировать видимые журналы';

  @override
  String get inlineAttribute_c16db1ad02461665 => 'Журналы отладки';

  @override
  String get inlineAttribute_f16edb7443f05225 => 'Обновить статус гостя';

  @override
  String get inlineAttribute_ca4ce07eeab21f24 => 'Личные подписки';

  @override
  String get inlineAttribute_ccccab7c5d91fcc1 => 'Release Highlights';

  @override
  String get inlineAttribute_0b33748029674d12 => 'Поиск страны, города, IP...';

  @override
  String get inlineAttribute_fd67fb8b214d0251 => 'Harmoney Update Available';

  @override
  String get inlineAttribute_0c16e4802957bf2a => 'Update Interrupted';

  @override
  String get inlineAttribute_a291d1863aeedb00 => 'Обнаружена повторяющаяся ссылка.';

  @override
  String get inlineAttribute_44bd7ae60f478fae => 'H';

  @override
  String get inlineAttribute_c97f606c82316bc1 => 'Экспортировать файл журнала';

  @override
  String get inlineAttribute_e09b37bcc4f301f4 => 'Имя (необязательно)';

  @override
  String get inlineAttribute_0ca0dfe5e1ff7a8e => 'Операции с учетной записью';

  @override
  String get inlineAttribute_c3812fc4acb861d5 => 'Удалить';

  @override
  String get inlineAttribute_3e695daee969126c => 'Package installer launched. Tap below if you need to relaunch.';

  @override
  String get inlineAttribute_48845bff334a50a5 => 'Dismiss';

  @override
  String get inlineAttribute_9b64398e9f8fef53 => 'Тестовый сервер';

  @override
  String get inlineAttribute_ea9d303a5e54fb42 => 'Фильтровать по этапу (ПОДГОТОВКА, IKE, АУТЕНТИФИКАЦИЯ, ВЕРИФИКАЦИЯ, ПОДКЛЮЧЕНИЕ, ОШИБКА) или ключевому слову…';

  @override
  String get inlineAttribute_d640c7421da06661 => 'Возобновить';

  @override
  String get inlineAttribute_140669bdb031e927 => 'Ссылка на подписку';

  @override
  String get inlineAttribute_16f78a7d6317f102 => 'имя пользователя';

  @override
  String get inlineAttribute_e1a0ff7a5353c7fe => 'Guest SSID';

  @override
  String get inlineAttribute_e098b630f04d6d69 => 'Домен или IP, чтобы объяснить';

  @override
  String get inlineAttribute_0f39d38fb65968d0 => 'Пароль подписки';

  @override
  String get inlineAttribute_858e4ba7a29fd38b => 'Пауза';

  @override
  String get inlineAttribute_3dea43271fc3f002 => 'Поиск установленных приложений или пакетов';

  @override
  String get inlineAttribute_ac8619ca1957889c => 'оставшиеся персональные подписки';

  @override
  String get inlineAttribute_f8a5decc321d9f7a => 'Поиск по стране, городу, IP-адресу...';

  @override
  String get inlineAttribute_82ab1760fe92313f => 'Ожидаете событий потока журнала подключений к механизму?';

  @override
  String get inlineAttribute_c0671aa2f2dd814a => 'Download & Update';

  @override
  String get inlineTextTemplate_2e5f79bb94a8c40b => 'Checking...';

  @override
  String get inlineTextTemplate_4b5e556c141daca0 => 'Не удалось обновить правило приложения: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_fe5115c86ab563dd => 'QZXVAR0QZX CIDRs';

  @override
  String get inlineTextTemplate_f6fd414931d6a430 => 'Проверка задержки не удалась: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_be6ee118f6ce86a8 => 'Downloading Update...';

  @override
  String get inlineTextTemplate_fe4eac0d19b1f8b2 => 'Не удалось экспортировать: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_846aa6f62acf906c => 'Не удалось удалить: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_1d653fc4503ec979 => 'The update will download and install directly inside Harmoney.';

  @override
  String get inlineTextTemplate_0b59208593d747ad => 'Не удалось добавить приложение: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_bfafae05cba5bb86 => 'Не удалось загрузить серверы: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_1a1e3bf73b281b6d => 'Не удалось загрузить настройки обхода приложения: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_3c17c68905f8856a => 'Ошибка: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_e52ff58d5b3af8f0 => 'Обход страны: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_8bc4d9b4f92c60ab => 'Не удалось обновить обход приложения: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_8df4368ecb09de86 => 'Не удалось разблокировать: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_0d1e9be15aed1231 => 'Подключенные устройства (QZXVAR0QZX)';

  @override
  String get inlineTextTemplate_601fcd78f13053e1 => '↓ QZXVAR0QZX Mbps';

  @override
  String get inlineTextTemplate_972ff659f6e27b76 => 'Получен идентификатор оборудования от QZXVAR0QZX (QZXVAR1QZX).';

  @override
  String get inlineTextTemplate_ccccab7c5d91fcc1 => 'Release Highlights';

  @override
  String get inlineTextTemplate_a170e1c90b9a1695 => 'Сохранено в QZXVAR0QZX';

  @override
  String get inlineTextTemplate_7e941c183788df69 => 'Пинг: QZXVAR0QZXms · Джиттер: QZXVAR1QZXms · QZXVAR2QZX';

  @override
  String get inlineTextTemplate_fd67fb8b214d0251 => 'Harmoney Update Available';

  @override
  String get inlineTextTemplate_0c16e4802957bf2a => 'Update Interrupted';

  @override
  String get inlineTextTemplate_e100a78e26906915 => 'QZXVAR0QZX осталось';

  @override
  String get inlineTextTemplate_e24a324bdb714d54 => 'Обновлено: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_a8f0cc53b0dca9ef => 'Не удалось удалить приложение: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_2347df78592d100a => 'QZXVAR0QZX выбраны страны (QZXVAR1QZX CIDRs)';

  @override
  String get inlineTextTemplate_73b6e48a1b552d11 => 'Later';

  @override
  String get inlineTextTemplate_c1c1009d3f37ec05 => 'Update';

  @override
  String get inlineTextTemplate_2b5bf24f64089836 => 'Ошибка аварийного останова: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_a4738b604a205c2e => 'Check Updates';

  @override
  String get inlineTextTemplate_3e695daee969126c => 'Package installer launched. Tap below if you need to relaunch.';

  @override
  String get inlineTextTemplate_005ef7725a64c7ed => 'New Version Available';

  @override
  String get inlineTextTemplate_e416fbfd7a91ed9f => 'Безопасно импортируйте профили QZXVAR0QZX WireGuard и QZXVAR1QZX OpenVPN.';

  @override
  String get inlineTextTemplate_892b097363290e03 => 'Статус: QZXVAR0QZX · Задержка: QZXVAR1QZX';

  @override
  String get inlineTextTemplate_876c1a21e4aca06e => 'Версия: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_48845bff334a50a5 => 'Dismiss';

  @override
  String get inlineTextTemplate_a1868bb4d6de7026 => 'Настройка устройства: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_df0ea8d18fa1b297 => 'Не поддерживается на QZXVAR0QZX';

  @override
  String get inlineTextTemplate_d437f3d2dc2207b4 => 'Не удалось обновить автозапуск: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_8e339613f844cd3f => 'QZXVAR0QZX Mbps (Ping QZXVAR1QZXms)';

  @override
  String get inlineTextTemplate_b0e17c2810653b13 => 'Install Now';

  @override
  String get inlineTextTemplate_251f8b3bcb3ff541 => 'Ни один импортированный профиль QZXVAR0QZX не ​​соответствует выбранным местоположениям Surfshark.';

  @override
  String get inlineTextTemplate_b027e90663d6b737 => 'QZXVAR0QZX местоположения';

  @override
  String get inlineTextTemplate_732cc46253cae40a => 'QZXVAR0QZXms';

  @override
  String get inlineTextTemplate_169e482cbbd960b7 => 'QZXVAR0QZX добавлены';

  @override
  String get inlineTextTemplate_10d0ba33ae09b3a4 => ': QZXVAR0QZX · Сегодня: QZXVAR1QZX';

  @override
  String get inlineTextTemplate_1ec56334a0b24b7c => '↑ QZXVAR0QZX Mbps';

  @override
  String get inlineTextTemplate_e61e185de8f8a9d7 => 'Не удалось отключиться: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_d6975653ba21c6a2 => 'Не удалось обновить Always-on VPN: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_c0671aa2f2dd814a => 'Download & Update';

  @override
  String get inlineTextTemplate_94fa013c0e7b11f3 => 'Расширенная системная маршрутизация на QZXVAR0QZX';

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
  String get inlineAttributeTemplate_2f1118ed7cdb58dc => 'Ни одна строка журнала не соответствует фильтру «QZXVAR0QZX» [QZXVAR1QZX].';

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
  String get inlineAttributeTemplate_4a4177e796293af3 => '⚠ Примечание: QZXVAR0QZX';

  @override
  String get inlineAttributeTemplate_fede49e2e980819c => 'Wi-Fi QR URI: QZXVAR0QZX';

  @override
  String get inlineAttributeTemplate_4511036a54304f80 => 'Update Download Complete';

  @override
  String get inlineAttributeTemplate_b0e17c2810653b13 => 'Install Now';

  @override
  String get appString_AboutUs => 'О нас';

  @override
  String get appString_AboutDescription => 'Harmoney разработан Harmoney; это современный и безопасный инструмент для свободного доступа к интернету.';

  @override
  String get appString_Connect => 'Подключиться';

  @override
  String get appString_Disconnect => 'Отключиться';

  @override
  String get appString_Connected => 'Подключено';

  @override
  String get appString_Disconnected => 'Отключено';

  @override
  String get appString_Locations => 'Локации';

  @override
  String get appString_Statistics => 'Скорость';

  @override
  String get appString_SplitTunnel => 'Раздельное туннелирование';

  @override
  String get appString_Hotspot => 'Точка доступа';

  @override
  String get appString_Protection => 'Защита';

  @override
  String get appString_LeakProtection => 'Защита от утечек данных';

  @override
  String get appString_SystemSafeguards => 'Защита системы';

  @override
  String get appString_CountryBypass => 'Обход страны';

  @override
  String get appString_Diagnostics => 'Диагностика';

  @override
  String get appString_Settings => 'Настройки';

  @override
  String get appString_Connection => 'Соединение';

  @override
  String get appString_AutoConnect => 'Автоподключение';

  @override
  String get appString_AutoConnectSubtitle => 'Подключаться автоматически в поддерживаемых сетях';

  @override
  String get appString_KillSwitch => 'Экстренное отключение';

  @override
  String get appString_KillSwitchSubtitle => 'Блокировать интернет при обрыве соединения VPN';

  @override
  String get appString_Protocol => 'Протокол';

  @override
  String get appString_VpnProvider => 'Провайдер VPN';

  @override
  String get appString_ProviderSeparated => 'Сетевой модуль изолирован для максимальной скорости';

  @override
  String get appString_Privacy => 'Конфиденциальность';

  @override
  String get appString_DnsLeakProtection => 'Защита от утечек DNS';

  @override
  String get appString_Ipv6LeakProtection => 'Защита от утечек IPv6';

  @override
  String get appString_Appearance => 'Внешний вид';

  @override
  String get appString_System => 'Системная';

  @override
  String get appString_Light => 'Светлая';

  @override
  String get appString_Dark => 'Темная';

  @override
  String get appString_Language => 'Язык приложения';

  @override
  String get appString_LoadApps => 'Загрузить приложения';

  @override
  String get appString_SearchingApps => 'Поиск приложений...';

  @override
  String get appString_BypassIran => 'Обход локальных сайтов';

  @override
  String get appString_ConnectedTo => 'Подключено к';

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
  String get desktopTrayOpenApplication => 'Открыть приложение';

  @override
  String get desktopTrayChooseServer => 'Выбрать сервер…';

  @override
  String get desktopTrayPreferences => 'Настройки';

  @override
  String get desktopTrayStartupOptions => 'Параметры запуска';

  @override
  String get desktopTrayLaunchOnStartup => 'Запускать при входе в систему';

  @override
  String get desktopTraySoundEffect => 'Звуковой эффект';

  @override
  String get desktopTrayStartMinimized => 'Запускать свёрнутым';

  @override
  String get desktopTrayForceClose => 'Полностью закрыть';

  @override
  String get desktopTrayServiceMode => 'Режим службы';

  @override
  String get desktopTrayProxyService => 'Прокси-служба';

  @override
  String get desktopTraySystemProxy => 'Системный прокси';

  @override
  String get desktopTrayVpnModeUnavailable => 'VPN (недоступно)';

  @override
  String get desktopTrayExit => 'Выход';

  @override
  String get desktopTrayReady => 'Готово';

  @override
  String get desktopTrayDisconnecting => 'Отключение…';

  @override
  String get desktopTrayCancelConnection => 'Отменить подключение';

  @override
  String get desktopTrayAutomatic => 'Автоматически';

  @override
  String get desktopTrayError => 'Ошибка';
}
