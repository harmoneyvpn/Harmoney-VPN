// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Harmoney VPN';

  @override
  String get splashSubtitle => '为安全的互联网访问而设计，\n为所有人，在任何地方';

  @override
  String get connect => '连接';

  @override
  String get disconnect => '断开连接';

  @override
  String get connected => '已连接';

  @override
  String get disconnected => '已断开';

  @override
  String get connecting => '正在连接';

  @override
  String connectingVia(String groupName) {
    return '正在通过 $groupName 连接';
  }

  @override
  String get switchingMethod => '切换方式中';

  @override
  String get speedTest => '速度测试';

  @override
  String get download => '下载';

  @override
  String get upload => '上传';

  @override
  String get ping => '延迟';

  @override
  String get latency => '延迟';

  @override
  String get jitter => '抖动';

  @override
  String get packetLoss => '丢包';

  @override
  String get tapHere => '点击这里';

  @override
  String get settings => '设置';

  @override
  String get introduction => '介绍';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsAndConditions => '条款和条件';

  @override
  String get ourWebsite => '我们的网站';

  @override
  String get marketplace => '市场';

  @override
  String get telegramBot => 'Telegram 机器人';

  @override
  String get sourceCode => '源代码';

  @override
  String get openSourceLicenses => '开源许可证';

  @override
  String get betaCommunity => '测试社区';

  @override
  String get close => '关闭';

  @override
  String get copyLogs => '复制日志';

  @override
  String get logsCopied => '日志已复制到剪贴板';

  @override
  String get appLogs => '应用日志';

  @override
  String get autoRefresh => '自动刷新';

  @override
  String get clear => '清除';

  @override
  String get quickMenu => '快速菜单';

  @override
  String get noInternet => '无网络连接';

  @override
  String get error => '错误';

  @override
  String get loading => '加载中';

  @override
  String get analyzing => '分析中';

  @override
  String get mbps => '兆比特/秒';

  @override
  String get ms => '毫秒';

  @override
  String get language => '语言';

  @override
  String get tips => '提示';

  @override
  String get english => 'English (英语)';

  @override
  String get chinese => '中文';

  @override
  String get gotIt => '知道了';

  @override
  String get learnMore => '了解更多';

  @override
  String get harmoneyGoal => 'Harmoney的目标是确保安全访问公共信息，并提供免费的浏览体验。';

  @override
  String get statusIsChilling => '正在休息。';

  @override
  String get statusIs => '是';

  @override
  String get statusFailed => '失败了。';

  @override
  String get statusHas => '有';

  @override
  String get statusIsReturning => '正在返回';

  @override
  String get statusToStandbyMode => '到待机模式。';

  @override
  String get statusPluggingIn => '连接中 ...';

  @override
  String get statusPoweredUp => '已启动';

  @override
  String get statusDoingScience => '正在工作 ...';

  @override
  String get statusExitedMatrix => '已退出矩阵';

  @override
  String get statusSorry => '我们很抱歉 :(';

  @override
  String get statusConnectAlready => '立即连接';

  @override
  String get statusTestingSpeed => '测试速度中 ...';

  @override
  String get statusIsReady => '已准备好';

  @override
  String get statusIsInTrouble => '遇到麻烦了.';

  @override
  String get statusDXcoreDown => 'DXcore 已关闭.';

  @override
  String get statusToSpeedTest => '进行速度测试';

  @override
  String get statusYoursToShape => '由您塑造';

  @override
  String get settingsConnectionMethod => '连接方式';

  @override
  String get settingsEscapeMode => '逃逸模式';

  @override
  String get settingsDestination => '目的地';

  @override
  String get settingsSplitTunnel => '分离隧道';

  @override
  String get settingsKillSwitch => '终止开关';

  @override
  String get settingsDeepScan => '深度扫描';

  @override
  String get settingsHealthCheck => '健康检查';

  @override
  String get settingsIncluded => '已包含';

  @override
  String get settingsAtLeastOneCoreRequired => '至少需要保留一个核心';

  @override
  String get settingsResetToDefault => '重置';

  @override
  String get offlineFlowlineMessage => '由于当前使用离线版本，Flowline更新已暂停。';

  @override
  String get offlineFlowlineUndo => '撤销';

  @override
  String get updateAvailable => '可用更新';

  @override
  String get updateRequired => '需要更新';

  @override
  String get updateOptionalMessage => '为了充分利用应用程序并享受最新改进，请更新到最新版本。';

  @override
  String get updateRequiredMessage => '要继续使用 Harmoney，请更新到最新版本。此更新包含关键改进，对应用功能必不可少。';

  @override
  String get updateNow => '立即更新';

  @override
  String get notNow => '暂不更新';

  @override
  String get updateMethods => '更新方法';

  @override
  String get importConfig => '导入配置';

  @override
  String get synchronization => '同步';

  @override
  String get settingsDonation => '捐赠';

  @override
  String get settingsDonationDescription => '帮助我们打破数字审查和互联网过滤的壁垒。';

  @override
  String get authenticationRequired => '需要身份验证';

  @override
  String get premiumLoginDescription => '要访问您的高级订阅，您需要通过 Harmoney 网站登录或创建账户。';

  @override
  String get email => '电子邮件';

  @override
  String get emailHint => 'example@domain.com';

  @override
  String get emailValidation => '请输入您的电子邮件';

  @override
  String get password => '密码';

  @override
  String get passwordHint => '输入您的密码';

  @override
  String get passwordValidation => '请输入您的密码';

  @override
  String get passwordMinLength => '密码至少需要6个字符';

  @override
  String get login => '登录';

  @override
  String get noAccount => '没有账户？';

  @override
  String get signUp => '注册';

  @override
  String get loginFailed => '登录失败。请检查您的凭据并重试。';

  @override
  String get loginSuccess => '登录成功！';

  @override
  String get code => '代码';

  @override
  String get codeHint => '输入您的访问代码';

  @override
  String get codeValidation => '请输入您的代码';

  @override
  String get premiumLoginByCodeDescription => '要访问您的高级订阅，请输入提供给您的访问代码。';

  @override
  String get havingTrouble => '遇到问题？';

  @override
  String get signedInAs => '您当前已使用电子邮件地址登录';

  @override
  String get premiumImportDescription => '如果由于互联网限制无法加载您的高级订阅，并且您无法使用可用方法连接，您可以将从市场获得的文件导入应用程序。';

  @override
  String get planningToExit => '打算退出？';

  @override
  String get signOut => '退出';

  @override
  String get signOutSuccess => '退出成功！';

  @override
  String get settingsMarketplace => '市场';

  @override
  String get marketplaceDescription => '浏览来自可信供应商的安全VPN配置。';

  @override
  String get loggedIn => '已登录';

  @override
  String get loginOrRegister => '登录或注册';

  @override
  String get loginByCode => '使用代码登录';

  @override
  String get backToLoginByEmail => '返回电子邮件登录';

  @override
  String get connectionRequired => '需要连接';

  @override
  String get connectionRequiredDescription => '要完成安全的登录或注册过程，您必须首先使用可用的连接方法之一建立连接。';

  @override
  String get inlineText_a5998db73b68af63 => '服务器设置';

  @override
  String get inlineText_3305ac4300665f71 => '自动扫描此设备';

  @override
  String get inlineText_fa7af603d430b209 => '取消';

  @override
  String get inlineText_9de2a0d933190a40 => 'Harmoney Pro';

  @override
  String get inlineText_9fd728c66c9a256b => '添加';

  @override
  String get inlineText_8450d81a2ef331f0 => '此平台不支持。';

  @override
  String get inlineText_6f759aed280d8ae1 => '硬件标识符重置为服务器默认值。';

  @override
  String get inlineText_10ae58fbb5984f6e => '在 Android 和 Linux 上，使用选定的订阅，但 VPN 核心可能会从中选择不同的节点。';

  @override
  String get inlineText_c01c4324f1fa14fc => '正在导入…';

  @override
  String get inlineText_ef207787e1f5054a => '此平台不支持按应用程序绕过。';

  @override
  String get inlineText_543264e2f45dd255 => '绕过 VPN';

  @override
  String get inlineText_034fc31b30e178f0 => '火狐VPN协议';

  @override
  String get inlineText_4fcf7e0d90445713 => '禁用：所有流量通过加密 VPN 隧道安全路由。';

  @override
  String get inlineText_272a96114c7af32f => '自定义绕过规则';

  @override
  String get inlineText_7b547a5ae60b2f38 => 'Firefox VPN';

  @override
  String get inlineText_4b42c738a9185fc5 => '热点活跃';

  @override
  String get inlineText_fa174cea0ac4357d => '保存设置';

  @override
  String get inlineText_5474eef8d0f179c7 => '正在处理中…';

  @override
  String get inlineText_e6f7f8ccc059e5c7 => '未选择任何应用程序。';

  @override
  String get inlineText_df8748e19fc6ee2b => '断开连接所花费的时间比预期要长。你可以再试一次。';

  @override
  String get inlineText_c0bd827e34b175ab => '阻止 Internet 访问';

  @override
  String get inlineText_7af2f7454f3b55aa => '刷新状态和配额';

  @override
  String get inlineText_eea2745e2867a677 => '核实';

  @override
  String get inlineText_88712c434b491bce => '需要登录';

  @override
  String get inlineText_7d9eb7acb13e2462 => '关闭';

  @override
  String get inlineText_46b5d935b82dd8e0 => '选择连接服务';

  @override
  String get inlineText_8035283793ddc0b5 => '查询最新会话及流量配额';

  @override
  String get inlineText_64a985f51e17518b => '无自定义绕过规则。';

  @override
  String get inlineText_90e0e260530759ce => '仅主机';

  @override
  String get inlineText_fa1cf54705b7a6ea => '生成设备硬件 ID';

  @override
  String get inlineText_8693a5d72c6b23fa => '与手机和平板电脑共享安全加密隧道';

  @override
  String get inlineText_0d21bd52022ca7f7 => '在线的';

  @override
  String get inlineText_7d096ae1ecf2a8cc => '绕过';

  @override
  String get inlineText_2fc9fc3695f14892 => '禁用优化';

  @override
  String get inlineText_6405b0129cf5a714 => '最终生成的 ID (SHA-256)：';

  @override
  String get inlineText_5f65ccdf701bd499 => '保存设置';

  @override
  String get inlineText_c90fdfab474bdd3e => '登录帐户';

  @override
  String get inlineText_1c114a72bff7ecbc => '修复ICS';

  @override
  String get inlineText_c3a6d1c87fa8d4bb => '速度测试历史';

  @override
  String get inlineText_4d9bfca28655ee45 => '会话上传：';

  @override
  String get inlineText_1a095c79818885e4 => '启动访客';

  @override
  String get inlineText_d18f4156fea49644 => '正在检查账户…';

  @override
  String get inlineText_ac7c949f1211b781 => '不活跃';

  @override
  String get inlineText_9c1ff072196e2d26 => '准备好执行实时路由和安全审核。';

  @override
  String get inlineText_df578dfdf0dafa9a => '尚未记录速度测试。';

  @override
  String get inlineText_5d6529256c6c68f0 => '直接启动';

  @override
  String get inlineText_23d5d93cf5f11e17 => '无限配额';

  @override
  String get inlineText_1228cd974a4510cf => '导出服务器';

  @override
  String get inlineText_0323bbb0e3e24d50 => '允许 IPv6';

  @override
  String get inlineText_58e27854800bc94b => '网络畅通：Kill switch、路由和 XFRM 接口恢复正常。';

  @override
  String get inlineText_d71035f8d7c85940 => '受保护的热点选项';

  @override
  String get inlineText_14bd9f9fb68a5859 => '选择 VPN 提供商';

  @override
  String get inlineText_cbca739d8ccd07e1 => '检查 XFRM 接口、表 220、IP 规则，并安全地验证实时连接。';

  @override
  String get inlineText_d0527e4b3d658351 => '退出';

  @override
  String get inlineText_f7fa281a488a9a0d => '50 GB';

  @override
  String get inlineText_a38c71d45d21c4ab => '仅通知';

  @override
  String get inlineText_b8352b44a588721c => '应用语言';

  @override
  String get inlineText_e55142a1acfd8059 => '用户名';

  @override
  String get inlineText_f2b10ce04701badc => '加载应用程序';

  @override
  String get inlineText_b1fe69e5cd48a270 => ' -  多发性硬化症';

  @override
  String get inlineText_989961ec7fc20bdd => '重新连接 VPN 后，将应用 Android 应用程序旁路。';

  @override
  String get inlineText_039b675cbfc3719c => 'HTTP/2 连接';

  @override
  String get inlineText_7366b74aba11b666 => '控制台输出已复制到剪贴板。';

  @override
  String get inlineText_0173658e5af8698d => '支持导出捆绑包并复制到剪贴板。';

  @override
  String get inlineText_9f658c229a11bef6 => '当移动热点处于活动状态时，为 VPN 适配器配置 Windows ICS。应用程序验证ICS绑定；客户端互联网流量仍然需要端到端检查。';

  @override
  String get inlineText_73997b80ca90ece7 => '当前没有设备连接到热点。';

  @override
  String get inlineText_ebf5f31bd3fa8cf4 => '取消测试';

  @override
  String get inlineText_4bfa799fae21b467 => '流量分析';

  @override
  String get inlineText_b28b26cf1cc18caf => '更平静的连接。一个更光明的世界。';

  @override
  String get inlineText_ed95556c5c93ded1 => '国家/地区和应用程序绕过';

  @override
  String get inlineText_4cf9134d1c9ed485 => '输出连接配置文件';

  @override
  String get inlineText_2a78025de6aae5e7 => '选择';

  @override
  String get inlineText_cbbea9d808ebfe70 => 'Surfshark';

  @override
  String get inlineText_88921e28030e4255 => '服务密码/私钥';

  @override
  String get inlineText_39c3183ee0cbb997 => '未配置高级策略规则。';

  @override
  String get inlineText_6cb8a5b3137a00c3 => '选定的国家/地区 IP 范围绕过 VPN。更改规则后重新连接。仅域规则需要 DNS 感知路由。';

  @override
  String get inlineText_8bb1de2dfce6294f => '正在启动连接…';

  @override
  String get inlineText_22965568d22a14ee => '已连接';

  @override
  String get inlineText_e7e2af717bdfb964 => '自动（后备）';

  @override
  String get inlineText_42b5bc901ede1799 => '100 GB';

  @override
  String get inlineText_24ef681c569b5c42 => '系统应用程序';

  @override
  String get inlineText_3e2421c56094293c => '路由表和 XFRM 验证';

  @override
  String get inlineText_5d7cd082fc9987e9 => '强制 VPN 加密';

  @override
  String get inlineText_1159717463f1ebc3 => '服务用户名/密钥 ID';

  @override
  String get inlineText_0e76960093379060 => '历史';

  @override
  String get inlineText_cb0bf46bf1e385db => '导入邮政编码';

  @override
  String get inlineText_2da236423b3b5ad5 => '常开和锁定盖支持 VPN 连接。 DNS 和 IPv6 策略由活动隧道强制执行。';

  @override
  String get inlineText_50829e8639527356 => '添加应用程序（.exe）';

  @override
  String get inlineText_f6f39fe075ffa5de => '在启用应用程序旁路之前添加应用程序。';

  @override
  String get inlineText_5a99f6fa7e98657a => '扫描二维码';

  @override
  String get inlineText_c4b6bf5634f8ce91 => '说明为什么目的地通过 VPN 或直接 ISP 进行路由，并具有规则优先级匹配。';

  @override
  String get inlineText_cf0883343f4abef7 => '协议';

  @override
  String get inlineText_adec3733feabdc2d => '文件已成功提取。';

  @override
  String get inlineText_0c567745c63c57bc => 'Android 支持 IPv4 和 IPv6 CIDR 绕过。更改这些路由后重新连接VPN；应用绕过在重新连接后也会生效。';

  @override
  String get inlineText_cb0544450e1be874 => '正在审核…';

  @override
  String get inlineText_9e19b3ae1edc6135 => 'Android 锁定已激活';

  @override
  String get inlineText_0acb9208ef119b21 => '打开移动热点';

  @override
  String get inlineText_61118b57b609e8fd => '管理连接、安全性和外观';

  @override
  String get inlineText_ed077f3d8125d60d => '打开';

  @override
  String get inlineText_bbf3d191d555c872 => '地点及路线';

  @override
  String get inlineText_c01d52ac9ed5701a => 'Harmoney Pro 连接错误';

  @override
  String get inlineText_25a76b0a4ba5c39d => '安全应用和 LKG';

  @override
  String get inlineText_967549497036d513 => '取消选择全部';

  @override
  String get inlineText_72a47f8e322a40de => '保护 HUD';

  @override
  String get inlineText_2398cc05005cca7f => '离线缓存就绪';

  @override
  String get inlineText_469f27ad0a12c557 => '此 ID 用作硬件指纹 (Hardware Device ID) 以对服务器上的设备进行身份验证。您可以更改值或获取自动：';

  @override
  String get inlineText_783547972fe4ca08 => 'IKEv2';

  @override
  String get inlineText_03f15c48644862ae => '默认热点路由';

  @override
  String get inlineText_bd5a05ddab828e6d => '启动访客 Wi-Fi';

  @override
  String get inlineText_4968fc7fef5ea571 => '剩余流量：';

  @override
  String get inlineText_52a0bc5a1f46b6a1 => 'Firefox 帐户';

  @override
  String get inlineText_bb93f3cc26e28600 => '临时隔离的访客 Wi-Fi，具有自动过期和子网隔离功能。';

  @override
  String get inlineText_b361f42b64c263d8 => '正在检查安全凭据库…';

  @override
  String get inlineText_7d037fcb85b5a1eb => '直接（绕过 VPN）';

  @override
  String get inlineText_e65731cec92db7d5 => 'VPN 操作已在运行。请等待其状态更新。';

  @override
  String get inlineText_f24d839a275e6eaa => '启用热点共享 (ICS)';

  @override
  String get inlineText_03a71a235bfb6b30 => '登录成功并且服务器列表已更新。';

  @override
  String get inlineText_52933373144828ee => 'Firefox 帐户电子邮件/用户';

  @override
  String get inlineText_d86322c4ceb937de => '重新连接后，国家/地区 IPv4 范围会绕过 VPN。应用程序旁路使用 Windows 物理接口并需要 Harmoney 服务。';

  @override
  String get inlineText_77f0b86ebfb47aa6 => '设备的硬件ID设置成功。';

  @override
  String get inlineText_35d7442440a55ab9 => '为了防止 Android 在后台终止 VPN 连接，请禁用此应用程序的电池优化。';

  @override
  String get inlineText_3da7d703985421ec => 'Firefox 数据余量';

  @override
  String get inlineText_316f766fb0bc3a72 => '管理 Firefox VPN 帐户';

  @override
  String get inlineText_69b95013a9101213 => '高级策略规则';

  @override
  String get inlineText_9d0c59a66cf45b32 => 'VPN 到热点 ICS 绑定已验证。';

  @override
  String get inlineText_7ae00a283ea9b728 => '会话已过期';

  @override
  String get inlineText_0dd786510199ca80 => '服务连接设置';

  @override
  String get inlineText_708e318e0225bc88 => '停止访客';

  @override
  String get inlineText_ad4b77a68783ec24 => '会话持续时间';

  @override
  String get inlineText_25dcc872936aab98 => 'Firefox 帐户凭据由本地 Windows 帮助程序直接发送到 Mozilla。密码不保存；仅将来连接所需的帐户令牌存储在本地。';

  @override
  String get inlineText_219113c4bbe2e98c => 'Windows 按应用程序旁路直接通过物理适配器路由选定的应用程序，独立于活动 VPN 协议。需要 Windows 构建支持和特权 Harmoney 服务。';

  @override
  String get inlineText_21e3324fcec20e63 => '0 GB（关闭）';

  @override
  String get inlineText_20636a0c41a3f954 => '高级路由和保护';

  @override
  String get inlineText_dc8bf418d2bb68a6 => '安全 VPN DNS';

  @override
  String get inlineText_a0b16ccf9021fc82 => '现场活跃';

  @override
  String get inlineText_abff5572a370fab7 => '已排队...';

  @override
  String get inlineText_b666d8596482e260 => 'Xray 会直接路由选定的 IPv4/IPv6 网段和内置的伊朗域名列表。更改规则后请重新连接。';

  @override
  String get inlineText_df74ccb45d0e395d => '通过直接、强制 VPN 或阻止路由特定目的地。';

  @override
  String get inlineText_1509f561f2416598 => '保存';

  @override
  String get inlineText_7122ed800123d8e7 => '强制热点 VPN DNS';

  @override
  String get inlineText_6b97c41651da98ce => '自动从系统硬件获取';

  @override
  String get inlineText_6f98676a0a7b4953 => '私人连接服务';

  @override
  String get inlineText_0fb48c86db0c3f8f => '阻止无 VPN';

  @override
  String get inlineText_2427a4a9d7993571 => '通话者日志';

  @override
  String get inlineText_da223b83cdddd9db => '运行热点医生';

  @override
  String get inlineText_a899ea0cfb536e60 => '续订会话令牌或切换帐户';

  @override
  String get inlineText_70e3135873ca12f3 => '登录加载服务器';

  @override
  String get inlineText_98e33b0f3104fcf1 => '应用领域';

  @override
  String get inlineText_c6c2daab1f7d2fe5 => '实时实时速度';

  @override
  String get inlineText_81e9f4e64a840785 => '添加至少一个应用程序来启用此功能。';

  @override
  String get inlineText_942087cc2d41e013 => '重试';

  @override
  String get inlineText_3fb9aa9bdbb56bb6 => '创建新列表';

  @override
  String get inlineText_47e52e5e678a2248 => '日志复制到剪贴板（秘密已编辑）。';

  @override
  String get inlineText_cf406ea597d7a11b => '诊断终端输出';

  @override
  String get inlineText_5c8925f30317c4ae => '阻止 IPv6（泄漏保护）';

  @override
  String get inlineText_d69fa3897fde1fd7 => '握手所需的服务用户名和密码';

  @override
  String get inlineText_f98a2522000fbae8 => '200 GB';

  @override
  String get inlineText_30dc86f4e57e4278 => '应用到设置';

  @override
  String get inlineText_14eee0b522b0a07f => '当 VPN 意外掉落时阻止所有互联网泄漏';

  @override
  String get inlineText_b813ec3c634e571c => '将选定的应用程序或网络子网路由到 VPN 外部。';

  @override
  String get inlineText_d21cca3751709e6f => '硬件支持的加密：凭证在平台库中加密。';

  @override
  String get inlineText_ff4fcf35e586d0ca => '候选端点';

  @override
  String get inlineText_85455433f68a0eea => '路由说明';

  @override
  String get inlineText_e6e283499c38fe99 => '测试全部';

  @override
  String get inlineText_df8bb62c5262aace => '打开文件夹';

  @override
  String get inlineText_ca4ce07eeab21f24 => '个人订阅';

  @override
  String get inlineText_ccccab7c5d91fcc1 => 'Release Highlights';

  @override
  String get inlineText_fbfd8ce759281a7c => '重新登录';

  @override
  String get inlineText_48a39c950b733f9d => '修复热点路由';

  @override
  String get inlineText_1f914c4386c0676e => '连接';

  @override
  String get inlineText_fd67fb8b214d0251 => 'Harmoney Update Available';

  @override
  String get inlineText_5e0104e1d0dd6cc2 => '启动速度测试';

  @override
  String get inlineText_9225ef77a358de37 => '常开和锁定涵盖 Firefox、WireGuard、IKEv2 和 OpenVPN。 DNS 和 IPv6 策略由每个活动隧道配置文件强制执行。';

  @override
  String get inlineText_04b476ffe80f996f => '启用每个应用程序绕过';

  @override
  String get inlineText_e0b8edec85fbec56 => '服务器配置（默认源代码 - 仅在 Debug 模式下）';

  @override
  String get inlineText_a47e46554344d955 => '中，以便更轻松地从命令行连接（密码以明文形式存储）';

  @override
  String get inlineText_23be2e66d9c671b4 => '加载已安装的应用程序以配置每个应用程序旁路。';

  @override
  String get inlineText_60cc8000034bbcc6 => '输入值并手动构建';

  @override
  String get inlineText_14ea6d8e1758ce8f => '登录 Harmoney Pro';

  @override
  String get inlineText_b764cdc0eab71374 => '未知';

  @override
  String get inlineText_55b98eedd56ac65c => '更多协议和连接选项';

  @override
  String get inlineText_aa669b285cc133bf => '思科';

  @override
  String get inlineText_5e414ee0c5da2dde => 'Ping 全部';

  @override
  String get inlineText_e281f68dc29144b2 => '添加 HTTP 或 HTTPS 订阅 URL。链接安全地存储在此设备上。';

  @override
  String get inlineText_90f46423c0074765 => '会议下载：';

  @override
  String get inlineText_36230e6a755f25c0 => '选定的应用程序直接使用物理网络。其他应用程序继续使用 VPN。';

  @override
  String get inlineText_e0166a69e70a0063 => '为和谐而启用';

  @override
  String get inlineText_68eda25757c8e549 => '已保存的订阅';

  @override
  String get inlineText_639a40e82b9a96f0 => '连接';

  @override
  String get inlineText_2a5c4cf3cff579c9 => '选择绕过 VPN 隧道并直接连接到互联网的应用程序。';

  @override
  String get inlineText_229b05d20a6d2706 => '火狐 VPN 帐户';

  @override
  String get inlineText_e1f42d830cee8336 => '连接服务';

  @override
  String get inlineText_69cd3590300a68c6 => '检查状态';

  @override
  String get inlineText_79f4939f31f74600 => 'Android 保护';

  @override
  String get inlineText_e9f61c5ca23f266f => '来自所有提供商和协议的实时连接事件';

  @override
  String get inlineText_a0610c3d3b91cb4f => 'Harmoney Smart';

  @override
  String get inlineText_c0671aa2f2dd814a => 'Download & Update';

  @override
  String get inlineText_1a938f00d128e40c => '实时速度和交通';

  @override
  String get inlineText_74ca300a6cadb68a => '热点 IPv6 策略';

  @override
  String get inlineText_c2ed1ff176791192 => '路由策略：';

  @override
  String get inlineText_b8b960fef99adfb1 => 'Harmoney Pro 需要登录';

  @override
  String get inlineText_a23e527773f02a67 => 'Harmoney';

  @override
  String get inlineText_2067e249c2b1e5de => '超出配额操作：';

  @override
  String get inlineText_3b61e4e936523550 => '解释';

  @override
  String get inlineText_bd8256cb9d1b917f => '规则适用于当前 VPN 路由。UDP 中继尚未完成；需要 UDP 的应用可能无法完全绕过 VPN。';

  @override
  String get inlineText_664479f12348ca20 => '开始提取';

  @override
  String get inlineText_2fd1a96a8b9a93c0 => 'Surfshark 服务帐户';

  @override
  String get inlineText_37d1bd40cc9b7ba7 => '使用 Windows 本机每进程路由直接通过物理网络适配器发送选定的应用程序。需要兼容的 Windows 版本和 Harmoney VPN 服务。';

  @override
  String get inlineText_e2419bb6585fdf13 => '国家/地区目的地直接通过 ISP 绕过 VPN；其他流量保留在 VPN 内。';

  @override
  String get inlineText_566bd7ec6c74731b => '系统上未检测到活动热点接口。';

  @override
  String get inlineText_1d653fc4503ec979 => 'The update will download and install directly inside Harmoney.';

  @override
  String get inlineText_9e4a7faff61f59aa => '硬件配置文件：Dell Latitude 7210 和英特尔/蜂窝 LTE';

  @override
  String get inlineText_515c0e6425c1c144 => '尚无 CIDR 规则。';

  @override
  String get inlineText_60c5a84642b61c53 => '在 Android VPN 设置中启用锁定';

  @override
  String get inlineText_cb222670e743b957 => '密码';

  @override
  String get inlineText_d1ad5bbe561caba5 => '块目标';

  @override
  String get inlineText_54b8e0c0c268c154 => '复制报告';

  @override
  String get inlineText_7539a050c6489953 => 'Harmoney Pro 下载链接暂不可用。';

  @override
  String get inlineText_4759498ac2a719c6 => '创建';

  @override
  String get inlineText_089899b425d4bcda => '添加订阅';

  @override
  String get inlineText_838c8e30c9aeac8a => '访客热点';

  @override
  String get inlineText_475e433587200d99 => '当 VPN 下降时保持国内服务和银行业务可访问';

  @override
  String get inlineText_0b4666b1dcc9f6f9 => '启用分割隧道';

  @override
  String get inlineText_cb2b6a572a8588d8 => '正在断开连接…';

  @override
  String get inlineText_fb94fc702eb62ab7 => '下载 Harmoney Pro';

  @override
  String get inlineText_ad7b66a913a46286 => '断开连接';

  @override
  String get inlineText_74a883a037bc227f => '设置';

  @override
  String get inlineText_6c2a96757bb1ab31 => 'API设置';

  @override
  String get inlineText_a63b3bb0ad3689a0 => '之前的 VPN 操作超时。你可以再试一次。';

  @override
  String get inlineText_b11e1aa7421b52e2 => '路由测试';

  @override
  String get inlineText_73b6e48a1b552d11 => 'Later';

  @override
  String get inlineText_c1c1009d3f37ec05 => 'Update';

  @override
  String get inlineText_fa488105cb65db88 => '安全会话已过期；请重新登录以使用服务器。';

  @override
  String get inlineText_4bd0e4ba0e817d11 => '无限（关闭）';

  @override
  String get inlineText_690dbe9dc0993c42 => '最近的';

  @override
  String get inlineText_005ef7725a64c7ed => 'New Version Available';

  @override
  String get inlineText_92723a5ff9689c3d => '来自 Xray、WARP 和 MASQUE 配置的路由。流量验证后会显示连接。';

  @override
  String get inlineText_c5842271209f9ff7 => '的连接 协议覆盖范围';

  @override
  String get inlineText_1fc9a387654d410f => '选择全部';

  @override
  String get inlineText_b0e17c2810653b13 => 'Install Now';

  @override
  String get inlineText_5aa9ef74c967df76 => '自定义位置列表';

  @override
  String get inlineText_ad208643ab98407d => '热点共享设置已保存。';

  @override
  String get inlineText_5e1133591cfeb5b0 => '仅热点客户端';

  @override
  String get inlineText_d636391ee4236395 => '还没有匹配的事件。启动VPN连接来收集日志。';

  @override
  String get inlineText_ebbe7ab0b58e10be => '扫描订阅二维码';

  @override
  String get inlineText_092283a13b34e9ed => '显示服务器';

  @override
  String get inlineText_e548577f0fd46659 => 'Firefox 帐户凭据由本机 Android 引擎直接发送到 Mozilla。加密的令牌永远不会进入 Flutter 存储。';

  @override
  String get inlineText_a836bff92bbc5af0 => '重新登录账户';

  @override
  String get inlineText_50688e3917acdfec => '将选定的服务器列表导出为 JSON 和 TXT 文件。';

  @override
  String get inlineText_9b13e877e4aa90a7 => '已登录';

  @override
  String get inlineText_854d3eab6d8d5d33 => '登录和加载服务器';

  @override
  String get inlineText_c0d31ce834b82a7e => '没有最喜欢的服务器。';

  @override
  String get inlineText_4511036a54304f80 => 'Update Download Complete';

  @override
  String get inlineText_76b23f49c19a08d8 => '将所有设备 DNS 查询重定向到 Surfshark DNS。';

  @override
  String get inlineText_5a23444828db654a => '管理';

  @override
  String get inlineText_5fedacfb015245b7 => '实时连接日志（流）';

  @override
  String get inlineText_7446eabf9cf13622 => 'IPv6 泄漏保护';

  @override
  String get inlineText_2de8796023cbb4c7 => '无限制设置';

  @override
  String get inlineText_7a7832e87a88a9c7 => 'WFP 独立于 IKEv2、WireGuard、OpenVPN 和 Xray 应用规则。 UDP 中继尚未完成，因此需要 UDP 的应用程序不会被完全绕过。';

  @override
  String get inlineText_a0e1a519f04a9b3e => '连接';

  @override
  String get inlineText_289afa804e34a45f => '锁定期间允许伊朗流量';

  @override
  String get inlineText_ce13fbfce966190e => '尚未添加订阅。';

  @override
  String get inlineText_893e490d64407b8e => '配额信息不可用';

  @override
  String get inlineText_9b89006aec802e94 => '实时日志';

  @override
  String get inlineText_630c2f1c0ee1b8d7 => '积极的';

  @override
  String get inlineText_92340695899bd2d8 => '积极的';

  @override
  String get inlineText_203229774cceb5f3 => '管理账户';

  @override
  String get inlineText_bf6ccf81398eed34 => '添加策略';

  @override
  String get inlineText_a9884f2d7e028e02 => '未找到导入的配置文件。\\n从 Surfshark 手动设置导入 ZIP 存档。';

  @override
  String get inlineText_0c16e4802957bf2a => 'Update Interrupted';

  @override
  String get inlineText_94f105a3d269670f => '选择位置或使用最快的服务器';

  @override
  String get inlineText_472590ae974d4c1f => '提供商';

  @override
  String get inlineText_5541de9515522b98 => '已断开连接';

  @override
  String get inlineText_0e223795fafb578e => '保护设置由 Android VpnService 应用，并在重新连接后生效。';

  @override
  String get inlineText_bfd402b2f6f38125 => '登入';

  @override
  String get inlineText_970c6a41454fa6ee => '总体隧道运行状况';

  @override
  String get inlineText_f4c3265a274f6fa8 => '通过支持的隧道路由 IPv6；重新连接以应用';

  @override
  String get inlineText_ecf1d7c868ee46fc => 'Mbps';

  @override
  String get inlineText_f9f60b474c0c751b => '启动访客热点';

  @override
  String get inlineText_a840a9de3127ef53 => 'FireTunnel 使用 Firefox 帐户进行身份验证。凭证仅发送到根隔离的本机助手；令牌永远不会进入 Flutter 存储。';

  @override
  String get inlineText_dcbf414d58c417be => '紧急停止';

  @override
  String get inlineText_4f5845ea70794fc8 => 'Harmoney 反审查核心';

  @override
  String get inlineText_0234c7f3ac8b5b71 => '启用应用程序绕过';

  @override
  String get inlineText_24b8d9733417f7f2 => '正在建立安全隧道…';

  @override
  String get inlineText_ec963ffc911b8401 => '正在检查…';

  @override
  String get inlineText_c46c2996102a4b2c => '加密隧道经过验证，零数据包泄漏。';

  @override
  String get inlineText_c0bf75bd78bf9572 => '改变';

  @override
  String get inlineText_bcc0bcc9140b0c97 => '登入';

  @override
  String get inlineText_e7977ed18b1df209 => '每个应用程序绕过';

  @override
  String get inlineText_0e91610117029a62 => '刷新';

  @override
  String get inlineText_6defafa2caa65304 => '配置';

  @override
  String get inlineText_651f94aafffed603 => '断开连接请求仍在处理中…';

  @override
  String get inlineText_8b9d3de8ae00c89c => '正在登录…';

  @override
  String get inlineText_58b2c361864f4c09 => '始终在线 VPN';

  @override
  String get inlineText_8aa2064e8f385ad3 => '服务凭证和密钥';

  @override
  String get inlineText_7bcc95e0b5bd34c6 => '每个应用 VPN 绕过';

  @override
  String get inlineText_be6ee118f6ce86a8 => 'Downloading Update...';

  @override
  String get inlineText_67865eaee364dcbe => '强制 HTTPS 流量通过 TCP/TLS 以实现一致的过滤。';

  @override
  String get inlineText_a52ace420f2175d0 => '全部';

  @override
  String get inlineText_2eb0c5a3ce65868c => '实时带宽、数据统计和配额';

  @override
  String get inlineText_54386d5a6b84b6e8 => '电池优化活动（打盹模式）';

  @override
  String get inlineText_d0e13ceb47c44a7f => '智能路由和个人订阅';

  @override
  String get inlineText_1924fc22b6e86d49 => '主动 Surfshark 协议';

  @override
  String get inlineText_1eecb5c3f3e93223 => '重新连接 VPN 以应用 Android CIDR 路由。';

  @override
  String get inlineText_0ef1d485c68962e3 => '默认服务器';

  @override
  String get inlineText_1e77e9d04f19d6d9 => '主机和热点客户端';

  @override
  String get inlineText_f5af9ab211b447cd => '速度报告已复制到剪贴板！';

  @override
  String get inlineText_edb18cd663b5e4de => '块 QUIC (UDP 443)';

  @override
  String get inlineText_ea32ef00138d4d85 => '管理连接的设备、带宽配额、访客 Wi-Fi 和路由策略。';

  @override
  String get inlineText_46ff63176dfa61e2 => '强制 VPN';

  @override
  String get inlineText_f6f75ce9317a16db => '强制配额';

  @override
  String get inlineText_72fe71cb37d209d2 => '刷新状态';

  @override
  String get inlineText_56b598dee4ddc136 => '最快 ⚡';

  @override
  String get inlineText_19766ed6ccb2f4a3 => '取消';

  @override
  String get inlineText_7a1f2a83aca9a081 => '收藏夹';

  @override
  String get inlineText_876662d1d94ad13b => '实时验证';

  @override
  String get inlineText_bf26c2ac087da6ff => '旁路';

  @override
  String get inlineText_dfe40efe921fe88e => '正在更新…';

  @override
  String get inlineText_247ea0cd6733f4fc => '执行紧急停止：进程终止且物理网络畅通无阻。';

  @override
  String get inlineText_7207233f2b0688ac => '快速连接';

  @override
  String get inlineText_3c4846f1083e22ec => '分割隧道';

  @override
  String get inlineText_ec93679622950c2c => '默认存储位置：';

  @override
  String get inlineText_a76e13b9839270eb => '恢复';

  @override
  String get inlineText_a4738b604a205c2e => 'Check Updates';

  @override
  String get inlineText_c4b662bd95db40f1 => '清除该设备中存储的凭据';

  @override
  String get inlineText_adde42042c5c3caa => '暂停设备连接';

  @override
  String get inlineText_200bc33c838b6604 => '默认服务器 ID';

  @override
  String get inlineText_ea61bc15688d1e48 => '复制了！';

  @override
  String get inlineText_d3ee5446e626ae8f => '网络子网 (CIDRs)';

  @override
  String get inlineText_1640ef1a61f9a5ee => '更新了国家/地区绕过 DAT 规则。重新连接 VPN 即可应用。';

  @override
  String get inlineText_d403c686f6a10480 => '正在连接';

  @override
  String get inlineText_351d257b580bc419 => '选择您想要的 VPN 网络提供商';

  @override
  String get inlineText_1b4154057e37a0ff => '登录 Harmoney Pro';

  @override
  String get inlineText_ae4e9b1ef2aa3860 => '选择 Surfshark 协议';

  @override
  String get inlineText_83b12c2216efb4fd => '清除';

  @override
  String get inlineText_269f0582347dbdf6 => '推荐快速路线';

  @override
  String get inlineText_9918aaf803c54fcf => '选择二维码图像';

  @override
  String get inlineText_307e253c39bae652 => '连接测试';

  @override
  String get inlineText_337db382095ce88d => '通过选定的 VPN 重定向设备 DNS 查询。';

  @override
  String get inlineText_5bb6d1b367fc7674 => 'WireGuard';

  @override
  String get inlineText_e8696f00501ad45a => '未找到已导入的配置。\n请从 Surfshark 手动设置中导入 ZIP 压缩包。';

  @override
  String get inlineText_b0230c537ca88c85 => '用户应用程序';

  @override
  String get inlineText_e9d51941d0c1f37b => 'VPN 热点共享 (Windows ICS)';

  @override
  String get inlineText_6bcc8512de553613 => '显示所有服务器';

  @override
  String get inlineText_9d4be9539f27c657 => '尚未创建自定义列表。';

  @override
  String get inlineText_782ec78be81185c6 => 'FireTunnel 令牌/密码';

  @override
  String get inlineText_8a76134e54b9cfac => '需要钥匙';

  @override
  String get inlineText_75081b593d15cf6e => '残疾人';

  @override
  String get inlineText_2e5f79bb94a8c40b => 'Checking...';

  @override
  String get inlineText_471354282a521dd1 => '新自定义列表';

  @override
  String get inlineText_c7a43600b2a6507c => '登录/帐户';

  @override
  String get inlineText_a919cfce15c49685 => '锁定模式（终止开关）';

  @override
  String get inlineText_dd9e7664f013c1e5 => '在特权平台密钥库中加密的凭证';

  @override
  String get inlineText_f50e254cf57f39fd => '限制为 128kbit/s';

  @override
  String get inlineText_4e1af7c74096cf0a => '操作失败';

  @override
  String get inlineText_43e3ece73ff8f4eb => '剩余';

  @override
  String get inlineText_e94356112ce4c59c => '热点和设备';

  @override
  String get inlineText_313cbecb4dd35728 => '关闭';

  @override
  String get inlineText_d6eafe8235910042 => '下载';

  @override
  String get inlineText_06bacdb5d18b0261 => '阻止互联网';

  @override
  String get inlineText_8200a83deae2141b => '添加 CIDR 规则';

  @override
  String get inlineText_a429cd15905e58a5 => '设置配额';

  @override
  String get inlineText_57c95945cb8fe988 => '安全保存 VPN 服务凭据。';

  @override
  String get inlineText_4ff946afb073da91 => '管理 VPN 配置文件';

  @override
  String get inlineText_9bf1e054ed4cbacb => '将用户名和密码保存在文本文件';

  @override
  String get inlineText_6cb535909a7f3875 => '运行全面审核';

  @override
  String get inlineText_8fcbf6bb3bf0b5a0 => '按延迟排序';

  @override
  String get inlineText_45ee3e003650a75f => '添加路由策略规则';

  @override
  String get inlineText_04b93833872cc896 => '已请求断开连接…';

  @override
  String get inlineText_ad3d9699142e5339 => '安全保存';

  @override
  String get inlineText_c63e407525237f8d => 'VPN 调试日志';

  @override
  String get inlineText_530692d19626e11a => 'Xray 直接路由选定的 IPv4/IPv6 范围和捆绑的伊朗域列表。 Windows IKEv2 路由注入仍然仅限 IPv4。更改规则后重新连接。';

  @override
  String get inlineText_7c147e122ed7eeac => 'OpenVPN';

  @override
  String get inlineText_e17b6227325e1a8d => '智能服务适用性';

  @override
  String get inlineText_73bfa58718abc908 => '隧道路径审核、泄漏测试、延迟探测和运行时遥测';

  @override
  String get inlineText_659e50811965fe84 => '每月津贴';

  @override
  String get inlineText_6a4c3a4483b04488 => 'Ping';

  @override
  String get inlineText_11a6767d5674c7e4 => '完成';

  @override
  String get inlineText_acfc5be785a9bb3d => '断开';

  @override
  String get inlineText_c3812fc4acb861d5 => 'Remove';

  @override
  String get inlineText_fe4f5f9fd7be7d92 => '客户端隔离';

  @override
  String get inlineText_865e89de78d94c74 => '上传';

  @override
  String get inlineText_0004bf6db9f12d54 => '更新国家/地区规则';

  @override
  String get inlineText_3e695daee969126c => 'Package installer launched. Tap below if you need to relaunch.';

  @override
  String get inlineText_a8b3ef62feba073f => '未找到服务器。';

  @override
  String get inlineText_9ef0f877893218f3 => 'Firefox VPN 令牌和身份验证';

  @override
  String get inlineText_23759997b3c59884 => '未知';

  @override
  String get inlineText_e3b78e09863c99ac => '热点医生和诊断';

  @override
  String get inlineText_48845bff334a50a5 => 'Dismiss';

  @override
  String get inlineText_54a0e8c17ebb21a1 => '错误';

  @override
  String get inlineText_c8fd5b73d111ee1d => '，作者：Harmoney';

  @override
  String get inlineText_44e1911932d93644 => '和谐专业服务';

  @override
  String get inlineText_f6be68de3c8d5e7d => '每月数据配额';

  @override
  String get inlineText_51452219a8542052 => '未配置端点候选。';

  @override
  String get inlineText_f493cd9c7ae396ec => '登录以激活 Firefox 隧道并查看数据配额。';

  @override
  String get inlineText_8e1b786c7913210c => '保存配额';

  @override
  String get inlineText_efb52e7172b77731 => '主题';

  @override
  String get inlineText_2c2648394a4fe357 => '添加分割隧道 CIDR';

  @override
  String get inlineText_ff6d5def69d21f32 => '防止连接的热点客户端直接通信。';

  @override
  String get inlineText_532eaabd9574880d => '测试';

  @override
  String get inlineText_02a2c8aa276c0c36 => '隧道管理的 DNS；重新连接即可申请';

  @override
  String get inlineText_abaf4ed786bb9340 => '始终绕过 VPN 的域、IPv4 地址或 CIDRs';

  @override
  String get inlineText_49a2fc4df1b8bad5 => '轻量级 Firefox VPN 隧道';

  @override
  String get inlineText_2faba03e2b8726a9 => '最后速度基准：';

  @override
  String get inlineText_5bb4dc6f47d4c040 => '连接';

  @override
  String get inlineText_9d4ad0b61b2359e9 => '导入 ZIP 存档';

  @override
  String get inlineText_243a20f9ba6c2892 => '当达到此限制时，您将收到视觉警报。';

  @override
  String get inlineText_d3ae19164d4f0f44 => '诊断与健康';

  @override
  String get inlineText_3dd7fcefed0e482c => '热点不活动';

  @override
  String get inlineAttribute_a4282e4b2298b90b => '的';

  @override
  String get inlineAttribute_1a765360a12ba19c => '搜索国家/地区...';

  @override
  String get inlineAttribute_74c8361a4a1ca4c4 => '路线操作';

  @override
  String get inlineAttribute_be6ee118f6ce86a8 => 'Downloading Update...';

  @override
  String get inlineAttribute_440488e7af1a1602 => '域名、IPv4 或 CIDR';

  @override
  String get inlineAttribute_1d653fc4503ec979 => 'The update will download and install directly inside Harmoney.';

  @override
  String get inlineAttribute_372167bb30249862 => '数据配额（MB，0 = 无限制）';

  @override
  String get inlineAttribute_4b329f46e3e4aa50 => '剩余';

  @override
  String get inlineAttribute_8d634757de9d475f => '✓ 已验证：所有检查均已通过（XFRM、表 220、HTTPS 跟踪）';

  @override
  String get inlineAttribute_b9893538a61f89ed => '订阅的用户名';

  @override
  String get inlineAttribute_2c80752638d7bd54 => '粘贴';

  @override
  String get inlineAttribute_df3b5afaf2778138 => '域或 IP';

  @override
  String get inlineAttribute_1803685bb41d1d8d => '订阅 URL';

  @override
  String get inlineAttribute_09231cb8338a0158 => '目标域或 CIDR（例如 1.1.1.1/32）';

  @override
  String get inlineAttribute_474276a023bed5d8 => '首选名称（可选）';

  @override
  String get inlineAttribute_69612b885a0aff86 => '热门服务器';

  @override
  String get inlineAttribute_e7cf3ef4f17c3999 => '密码';

  @override
  String get inlineAttribute_f3380f7b44bd70af => '粘贴';

  @override
  String get inlineAttribute_ad0eae0c2cd935dc => 'armoney';

  @override
  String get inlineAttribute_3c128b5436b6d704 => '刷新全部';

  @override
  String get inlineAttribute_969ccbd3cf6300ec => '电子邮件';

  @override
  String get inlineAttribute_1b37568c4311efeb => '按应用名称或程序包搜索';

  @override
  String get inlineAttribute_4524cd31be7128c2 => '例如剩余 192.168.1.0/24 或 10.0.0.1/32';

  @override
  String get inlineAttribute_6077b2acb8754468 => '启用端点';

  @override
  String get inlineAttribute_b84364651ab4f422 => 'CIDR 或 IP';

  @override
  String get inlineAttribute_73b6e48a1b552d11 => 'Later';

  @override
  String get inlineAttribute_be420e2629f2ebfa => '电子邮件验证码';

  @override
  String get inlineAttribute_c1c1009d3f37ec05 => 'Update';

  @override
  String get inlineAttribute_b29904a25f1802a7 => '持续时间（分钟，5-1440）';

  @override
  String get inlineAttribute_a4738b604a205c2e => 'Check Updates';

  @override
  String get inlineAttribute_428ffb88a815b9be => '清除视图';

  @override
  String get inlineAttribute_6016fb957fe261cc => '更新全部';

  @override
  String get inlineAttribute_005ef7725a64c7ed => 'New Version Available';

  @override
  String get inlineAttribute_a1ab6eca52db1b3b => '测试服务器';

  @override
  String get inlineAttribute_4504b2c82bef3d20 => '复制日志';

  @override
  String get inlineAttribute_356c851e4ec59a3d => '配置设备';

  @override
  String get inlineAttribute_c2ef8dd2545d2b04 => '列表名称（例如欧洲快速）';

  @override
  String get inlineAttribute_f69c34c2fc4b9667 => '最喜欢的服务器';

  @override
  String get inlineAttribute_00ea6b3b42dfb4b5 => '个性化并手动创建硬件 ID';

  @override
  String get inlineAttribute_b073f6c68ef87211 => '范围';

  @override
  String get inlineAttribute_59ca629220a63ede => '删除';

  @override
  String get inlineAttribute_47311af432a79c40 => '删除配置文件';

  @override
  String get inlineAttribute_80884fb559e05bd9 => '禁用端点';

  @override
  String get inlineAttribute_b0e17c2810653b13 => 'Install Now';

  @override
  String get inlineAttribute_6769ff871d28e2ce => '关闭输出';

  @override
  String get inlineAttribute_01e8ee2044c91ec5 => '•••••••••••••••';

  @override
  String get inlineAttribute_cdf0cf9ecdfecba8 => '自定义列表';

  @override
  String get inlineAttribute_05eccbc907509b4b => '速度限制（kbit/s，0 = 无限制）';

  @override
  String get inlineAttribute_d4e54f76384bf545 => '重试探测';

  @override
  String get inlineAttribute_d3a8a299660b14d0 => '清除日志';

  @override
  String get inlineAttribute_7a3517625d7f32a6 => '复制输出';

  @override
  String get inlineAttribute_96f681e1e0e80f53 => '按提供商、协议、状态或错误过滤';

  @override
  String get inlineAttribute_4511036a54304f80 => 'Update Download Complete';

  @override
  String get inlineAttribute_2e5f79bb94a8c40b => 'Checking...';

  @override
  String get inlineAttribute_842d8e425ecb5b64 => '??';

  @override
  String get inlineAttribute_ce21ed09a64c529b => '检测到复制的订阅链接。';

  @override
  String get inlineAttribute_1e5a5a18ae04113a => '快捷菜单';

  @override
  String get inlineAttribute_c611981fab983bc6 => '策略';

  @override
  String get inlineAttribute_43e3ece73ff8f4eb => '剩余';

  @override
  String get inlineAttribute_a624a1e41ffdc6d6 => '来自';

  @override
  String get inlineAttribute_fb156130b17c4be3 => '帐户选项';

  @override
  String get inlineAttribute_0e08705e56eb56d8 => '复制可见日志';

  @override
  String get inlineAttribute_c16db1ad02461665 => '调试日志';

  @override
  String get inlineAttribute_f16edb7443f05225 => '刷新访客状态';

  @override
  String get inlineAttribute_ca4ce07eeab21f24 => '个人订阅';

  @override
  String get inlineAttribute_ccccab7c5d91fcc1 => 'Release Highlights';

  @override
  String get inlineAttribute_0b33748029674d12 => '搜索国家/地区、城市、IP...';

  @override
  String get inlineAttribute_fd67fb8b214d0251 => 'Harmoney Update Available';

  @override
  String get inlineAttribute_0c16e4802957bf2a => 'Update Interrupted';

  @override
  String get inlineAttribute_a291d1863aeedb00 => '发现重复的链接。';

  @override
  String get inlineAttribute_44bd7ae60f478fae => 'H';

  @override
  String get inlineAttribute_c97f606c82316bc1 => '导出日志文件';

  @override
  String get inlineAttribute_e09b37bcc4f301f4 => '名称（可选）';

  @override
  String get inlineAttribute_0ca0dfe5e1ff7a8e => '账户操作';

  @override
  String get inlineAttribute_c3812fc4acb861d5 => '删除';

  @override
  String get inlineAttribute_3e695daee969126c => 'Package installer launched. Tap below if you need to relaunch.';

  @override
  String get inlineAttribute_48845bff334a50a5 => 'Dismiss';

  @override
  String get inlineAttribute_9b64398e9f8fef53 => '测试服务器';

  @override
  String get inlineAttribute_ea9d303a5e54fb42 => '按阶段（准备、IKE、身份验证、验证、已连接、失败）或关键字过滤...';

  @override
  String get inlineAttribute_d640c7421da06661 => '恢复';

  @override
  String get inlineAttribute_140669bdb031e927 => '订阅链接';

  @override
  String get inlineAttribute_16f78a7d6317f102 => '用户名';

  @override
  String get inlineAttribute_e1a0ff7a5353c7fe => '访客 SSID';

  @override
  String get inlineAttribute_e098b630f04d6d69 => '域或 IP 说明';

  @override
  String get inlineAttribute_0f39d38fb65968d0 => '订阅密码';

  @override
  String get inlineAttribute_858e4ba7a29fd38b => '暂停';

  @override
  String get inlineAttribute_3dea43271fc3f002 => '搜索已安装的应用程序或软件包';

  @override
  String get inlineAttribute_ac8619ca1957889c => '个人订阅';

  @override
  String get inlineAttribute_f8a5decc321d9f7a => '搜索国家、城市、IP...';

  @override
  String get inlineAttribute_82ab1760fe92313f => '正在等待引擎连接日志流事件？';

  @override
  String get inlineAttribute_c0671aa2f2dd814a => 'Download & Update';

  @override
  String get inlineTextTemplate_2e5f79bb94a8c40b => 'Checking...';

  @override
  String get inlineTextTemplate_4b5e556c141daca0 => '无法更新应用程序规则： QZXVAR0QZX';

  @override
  String get inlineTextTemplate_fe5115c86ab563dd => 'QZXVAR0QZX CIDRs';

  @override
  String get inlineTextTemplate_f6fd414931d6a430 => '延迟测试失败：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_be6ee118f6ce86a8 => 'Downloading Update...';

  @override
  String get inlineTextTemplate_fe4eac0d19b1f8b2 => '导出失败：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_846aa6f62acf906c => '删除失败：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_1d653fc4503ec979 => 'The update will download and install directly inside Harmoney.';

  @override
  String get inlineTextTemplate_0b59208593d747ad => '无法添加应用程序：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_bfafae05cba5bb86 => '无法加载服务器：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_1a1e3bf73b281b6d => '无法加载应用程序绕过设置：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_3c17c68905f8856a => '错误：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_e52ff58d5b3af8f0 => '国家/地区绕过：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_8bc4d9b4f92c60ab => '无法更新应用程序绕过：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_8df4368ecb09de86 => '解除堵塞失败：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_0d1e9be15aed1231 => '连接的设备 (QZXVAR0QZX)';

  @override
  String get inlineTextTemplate_601fcd78f13053e1 => '↓ QZXVAR0QZX Mbps';

  @override
  String get inlineTextTemplate_972ff659f6e27b76 => '从 QZXVAR0QZX (QZXVAR1QZX) 接收到硬件 ID。';

  @override
  String get inlineTextTemplate_ccccab7c5d91fcc1 => 'Release Highlights';

  @override
  String get inlineTextTemplate_a170e1c90b9a1695 => '保存到 QZXVAR0QZX';

  @override
  String get inlineTextTemplate_7e941c183788df69 => 'Ping：QZXVAR0QZXms · 抖动： QZXVAR1QZXms · QZXVAR2QZX';

  @override
  String get inlineTextTemplate_fd67fb8b214d0251 => 'Harmoney Update Available';

  @override
  String get inlineTextTemplate_0c16e4802957bf2a => 'Update Interrupted';

  @override
  String get inlineTextTemplate_e100a78e26906915 => 'QZXVAR0QZX 左';

  @override
  String get inlineTextTemplate_e24a324bdb714d54 => '更新： QZXVAR0QZX';

  @override
  String get inlineTextTemplate_a8f0cc53b0dca9ef => '无法删除应用程序：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_2347df78592d100a => 'QZXVAR0QZX 所选国家/地区 (QZXVAR1QZX CIDRs)';

  @override
  String get inlineTextTemplate_73b6e48a1b552d11 => 'Later';

  @override
  String get inlineTextTemplate_c1c1009d3f37ec05 => 'Update';

  @override
  String get inlineTextTemplate_2b5bf24f64089836 => '紧急停止错误： QZXVAR0QZX';

  @override
  String get inlineTextTemplate_a4738b604a205c2e => 'Check Updates';

  @override
  String get inlineTextTemplate_3e695daee969126c => 'Package installer launched. Tap below if you need to relaunch.';

  @override
  String get inlineTextTemplate_005ef7725a64c7ed => 'New Version Available';

  @override
  String get inlineTextTemplate_e416fbfd7a91ed9f => '安全导入 QZXVAR0QZX WireGuard 和 QZXVAR1QZX OpenVPN 配置文件。';

  @override
  String get inlineTextTemplate_892b097363290e03 => '状态：QZXVAR0QZX · 延迟：QZXVAR1QZX';

  @override
  String get inlineTextTemplate_876c1a21e4aca06e => '版本：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_48845bff334a50a5 => 'Dismiss';

  @override
  String get inlineTextTemplate_a1868bb4d6de7026 => '配置设备： QZXVAR0QZX';

  @override
  String get inlineTextTemplate_df0ea8d18fa1b297 => 'QZXVAR0QZX 不支持';

  @override
  String get inlineTextTemplate_d437f3d2dc2207b4 => '更新自动启动失败：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_8e339613f844cd3f => 'QZXVAR0QZX Mbps（Ping QZXVAR1QZXms）';

  @override
  String get inlineTextTemplate_b0e17c2810653b13 => 'Install Now';

  @override
  String get inlineTextTemplate_251f8b3bcb3ff541 => '没有导入的 QZXVAR0QZX 配置文件与选定的 Surfshark 位置匹配。';

  @override
  String get inlineTextTemplate_b027e90663d6b737 => 'QZXVAR0QZX 位置';

  @override
  String get inlineTextTemplate_732cc46253cae40a => 'QZXVAR0QZXms';

  @override
  String get inlineTextTemplate_169e482cbbd960b7 => 'QZXVAR0QZX 添加';

  @override
  String get inlineTextTemplate_10d0ba33ae09b3a4 => '保单：QZXVAR0QZX · 今天：QZXVAR1QZX';

  @override
  String get inlineTextTemplate_1ec56334a0b24b7c => '↑ QZXVAR0QZX Mbps';

  @override
  String get inlineTextTemplate_e61e185de8f8a9d7 => '断开连接失败：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_d6975653ba21c6a2 => '更新常亮 VPN 失败：QZXVAR0QZX';

  @override
  String get inlineTextTemplate_c0671aa2f2dd814a => 'Download & Update';

  @override
  String get inlineTextTemplate_94fa013c0e7b11f3 => 'QZXVAR0QZX 上的高级系统路由';

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
  String get inlineAttributeTemplate_2f1118ed7cdb58dc => '没有与过滤器“QZXVAR0QZX”[QZXVAR1QZX] 匹配的日志行。';

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
  String get inlineAttributeTemplate_4a4177e796293af3 => '⚠ 通知：QZXVAR0QZX';

  @override
  String get inlineAttributeTemplate_fede49e2e980819c => 'Wi-Fi QR URI：QZXVAR0QZX';

  @override
  String get inlineAttributeTemplate_4511036a54304f80 => 'Update Download Complete';

  @override
  String get inlineAttributeTemplate_b0e17c2810653b13 => 'Install Now';

  @override
  String get appString_AboutUs => '关于我们';

  @override
  String get appString_AboutDescription => 'Harmoney 由 Harmoney 开发；一个安全、现代且快速的工具，用于自由畅连全球互联网。';

  @override
  String get appString_Connect => '连接';

  @override
  String get appString_Disconnect => '断开连接';

  @override
  String get appString_Connected => '已连接';

  @override
  String get appString_Disconnected => '已断开';

  @override
  String get appString_Locations => '节点位置';

  @override
  String get appString_Statistics => '测速与统计';

  @override
  String get appString_SplitTunnel => '分流设置';

  @override
  String get appString_Hotspot => '热点共享';

  @override
  String get appString_Protection => '安全保护';

  @override
  String get appString_LeakProtection => '数据泄漏防护';

  @override
  String get appString_SystemSafeguards => '系统防护';

  @override
  String get appString_CountryBypass => '国家/地区绕过';

  @override
  String get appString_Diagnostics => '诊断';

  @override
  String get appString_Settings => '设置';

  @override
  String get appString_Connection => '连接';

  @override
  String get appString_AutoConnect => '自动连接';

  @override
  String get appString_AutoConnectSubtitle => '在支持的网络上自动建立连接';

  @override
  String get appString_KillSwitch => '终止开关';

  @override
  String get appString_KillSwitchSubtitle => 'VPN 断开时立即切断网络，防止数据泄漏';

  @override
  String get appString_Protocol => '协议';

  @override
  String get appString_VpnProvider => 'VPN 核心';

  @override
  String get appString_ProviderSeparated => '核心连接层已优化以实现极速与稳定性';

  @override
  String get appString_Privacy => '隐私与安全';

  @override
  String get appString_DnsLeakProtection => 'DNS 防泄漏保护';

  @override
  String get appString_Ipv6LeakProtection => 'IPv6 防泄漏保护';

  @override
  String get appString_Appearance => '外观主题';

  @override
  String get appString_System => '跟随系统';

  @override
  String get appString_Light => '浅色';

  @override
  String get appString_Dark => '深色现代';

  @override
  String get appString_Language => '应用语言';

  @override
  String get appString_LoadApps => '加载应用列表';

  @override
  String get appString_SearchingApps => '搜索应用...';

  @override
  String get appString_BypassIran => '直连国内网站';

  @override
  String get appString_ConnectedTo => '已连接至';

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
  String get desktopTrayOpenApplication => '打开应用';

  @override
  String get desktopTrayChooseServer => '选择服务器…';

  @override
  String get desktopTrayPreferences => '偏好设置';

  @override
  String get desktopTrayStartupOptions => '启动选项';

  @override
  String get desktopTrayLaunchOnStartup => '开机时启动';

  @override
  String get desktopTraySoundEffect => '声音效果';

  @override
  String get desktopTrayStartMinimized => '启动时最小化';

  @override
  String get desktopTrayForceClose => '完全退出';

  @override
  String get desktopTrayServiceMode => '服务模式';

  @override
  String get desktopTrayProxyService => '代理服务';

  @override
  String get desktopTraySystemProxy => '系统代理';

  @override
  String get desktopTrayVpnModeUnavailable => 'VPN（不可用）';

  @override
  String get desktopTrayExit => '退出';

  @override
  String get desktopTrayReady => '就绪';

  @override
  String get desktopTrayDisconnecting => '正在断开…';

  @override
  String get desktopTrayCancelConnection => '取消连接';

  @override
  String get desktopTrayAutomatic => '自动';

  @override
  String get desktopTrayError => '错误';
}
