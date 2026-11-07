import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:file_picker/file_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/linux_platform_controls.dart';
import '../../core/local_cache_service.dart';
import '../../core/mobile_vpn_bridge.dart';
import '../../core/windows_per_app_split_tunnel.dart';
import '../../shared/services/haptic_service.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

enum SplitAppFilter { all, user, system }

class SplitTunnelPage extends StatefulWidget {
  const SplitTunnelPage({super.key});

  @override
  State<SplitTunnelPage> createState() => _SplitTunnelPageState();
}

class _SplitTunnelPageState extends State<SplitTunnelPage> {
  final controls = LinuxPlatformControls();
  bool enabled = false;
  bool loading = true;
  bool loadingApps = false;
  List<Map<String, dynamic>> rules = const [];
  List<Map<String, dynamic>> appRules = const [];
  List<Map<String, dynamic>> apps = const [];
  String appQuery = '';
  SplitAppFilter filter = SplitAppFilter.all;

  bool get isSupported =>
      Platform.isLinux || Platform.isAndroid || Platform.isWindows;

  @override
  void initState() {
    super.initState();
    _reload().then((_) {
      if (mounted) _loadApps();
    });
  }

  Future<void> _reload() async {
    if (Platform.isWindows) {
      await LocalCacheService.instance.init();
      final paths = LocalCacheService.instance.getWindowsPerAppExecutables();
      if (!mounted) return;
      setState(() {
        enabled = LocalCacheService.instance.getWindowsPerAppEnabled();
        appRules = paths
            .map(
              (path) => {
                'desktop_id': path,
                'name': path.split(Platform.pathSeparator).last,
                'mode': 'bypass',
              },
            )
            .toList();
        apps = List<Map<String, dynamic>>.from(appRules);
        loading = false;
      });
    } else if (Platform.isLinux) {
      try {
        final state = await controls.splitStatus();
        if (!mounted) return;
        setState(() {
          enabled = state['enabled'] == true;
          rules = (state['rules'] as List? ?? const [])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
          // Linux app entries are legacy UI selections only. The Linux helper
          // does not enforce them for running processes; direct launch is the
          // supported app-level path on this platform.
          appRules = const [];
          loading = false;
        });
      } catch (_) {
        if (mounted) setState(() => loading = false);
      }
    } else if (Platform.isAndroid) {
      try {
        final state = await MobileVpnBridge.protectionState();
        if (!mounted) return;
        final pkgs = (state['disallowed_packages'] as List? ?? const [])
            .map((p) => '$p')
            .toList();
        final cidrs = (state['split_cidrs'] as List? ?? const [])
            .map((cidr) => '$cidr')
            .toList();

        // Also check cached split packages if available
        final cached = LocalCacheService.instance.getSplitTunnelPackages();
        final combined = {...pkgs, ...cached}.toList();

        setState(() {
          enabled = state['split_tunneling'] == true ||
              state['split_enabled'] == true;
          rules =
              cidrs.map((cidr) => {'target': cidr, 'mode': 'bypass'}).toList();
          appRules = combined
              .map(
                (pkg) => {
                  'desktop_id': pkg,
                  'name':
                      pkg.split('.').last.replaceAll('_', ' ').toUpperCase(),
                  'package': pkg,
                  'mode': 'bypass',
                },
              )
              .toList();
          loading = false;
        });
      } catch (_) {
        if (mounted) setState(() => loading = false);
      }
    } else {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadApps({bool force = false}) async {
    if (loadingApps || (!force && apps.isNotEmpty) || !isSupported) return;
    setState(() => loadingApps = true);
    try {
      if (Platform.isWindows) {
        final paths = LocalCacheService.instance.getWindowsPerAppExecutables();
        if (mounted) {
          setState(
            () => apps = paths
                .map(
                  (path) => {
                    'desktop_id': path,
                    'name': path.split(Platform.pathSeparator).last,
                    'mode': 'bypass',
                  },
                )
                .toList(),
          );
        }
      } else if (Platform.isLinux) {
        final result = await controls.listDesktopApps();
        if (mounted) setState(() => apps = result);
      } else if (Platform.isAndroid) {
        try {
          // Use installed_apps to fetch real icons and app details
          final List<AppInfo> installed = await InstalledApps.getInstalledApps(
            false, // Include system apps so user can filter
            true, // withIcon: true for genuine app icons
            '',
          );
          final userApps = await InstalledApps.getInstalledApps(
            true,
            false,
            '',
          );
          final userPackages = userApps.map((app) => app.packageName).toSet();

          if (mounted) {
            setState(() {
              apps = installed.map((app) {
                // Cache icon in LocalCacheService
                if (app.icon != null && app.icon!.isNotEmpty) {
                  LocalCacheService.instance.cacheAppIcon(
                    app.packageName,
                    app.icon!,
                  );
                }
                return {
                  'desktop_id': app.packageName,
                  'name': app.name.isNotEmpty ? app.name : app.packageName,
                  'package': app.packageName,
                  'icon': app.icon,
                  'is_system': !userPackages.contains(app.packageName),
                };
              }).toList();
            });
          }
        } catch (_) {
          // Fallback to MobileVpnBridge if installed_apps plugin encounters permission issues
          final packages = await MobileVpnBridge.listInstalledAppPackages();
          if (mounted) {
            setState(() {
              apps = packages
                  .map(
                    (pkg) => {
                      'desktop_id': pkg,
                      'name': pkg
                          .split('.')
                          .last
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                      'package': pkg,
                      'icon': LocalCacheService.instance.getCachedAppIcon(pkg),
                      'is_system': false,
                    },
                  )
                  .toList();
            });
          }
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: LocalizedText(error.toString())));
      }
    } finally {
      if (mounted) setState(() => loadingApps = false);
    }
  }

  bool _isAppBypassed(String id) {
    return appRules.any(
      (r) =>
          (r['desktop_id'] == id || r['package'] == id) &&
          (r['mode'] == 'bypass' || r['mode'] == null),
    );
  }

  Future<void> _toggleAppBypass(Map<String, dynamic> app) async {
    HapticService.switchToggle();
    final desktopId = '${app['desktop_id'] ?? app['package']}';
    final currentlyBypassed = _isAppBypassed(desktopId);

    try {
      if (Platform.isAndroid) {
        final currentBypassed =
            appRules.map((a) => '${a['desktop_id'] ?? a['package']}').toSet();
        if (currentlyBypassed) {
          currentBypassed.remove(desktopId);
        } else {
          currentBypassed.add(desktopId);
        }
        final list = currentBypassed.toList();
        await MobileVpnBridge.setAppSplitTunneling(
          allowedPackages: const [],
          disallowedPackages: list,
        );
        await LocalCacheService.instance.saveSplitTunnelPackages(list);

        if (mounted) {
          setState(() {
            appRules = currentBypassed
                .map(
                  (pkg) => {'desktop_id': pkg, 'name': pkg, 'mode': 'bypass'},
                )
                .toList();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: LocalizedText(
                'Android app bypass applies after reconnecting the VPN.',
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: LocalizedText('Failed to update app rule: $error')),
        );
      }
    }
  }

  Future<void> _launchDirect(Map<String, dynamic> app) async {
    try {
      final result = await controls.launchAppDirect('${app['desktop_id']}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LocalizedText(
            '${result['name'] ?? app['name']} launched outside VPN.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: LocalizedText(error.toString())));
      }
    }
  }

  Future<void> _setEnabled(bool value) async {
    HapticService.switchToggle();
    try {
      if (Platform.isWindows) {
        final paths = appRules
            .map((app) => '${app['desktop_id'] ?? app['package']}')
            .toList();
        await WindowsPerAppSplitTunnel.configure(
          enabled: value,
          executables: paths,
        );
        await LocalCacheService.instance.saveWindowsPerAppEnabled(value);
        if (mounted) setState(() => enabled = value);
      } else if (Platform.isLinux) {
        final state = await controls.setSplitEnabled(value);
        if (!mounted) return;
        setState(() {
          enabled = state['enabled'] == true;
          rules = (state['rules'] as List? ?? const [])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
          appRules = const [];
        });
      } else if (Platform.isAndroid) {
        final pkgs =
            appRules.map((a) => '${a['desktop_id'] ?? a['package']}').toList();
        await MobileVpnBridge.setAppSplitTunneling(
          allowedPackages: const [],
          disallowedPackages: value ? pkgs : const [],
        );
        await MobileVpnBridge.setSplitCidrBypass(
          enabled: value,
          cidrs: rules.map((rule) => '${rule['target']}').toList(),
        );
        await LocalCacheService.instance.saveSplitTunnelPackages(pkgs);
        if (mounted) {
          setState(() => enabled = value);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: LocalizedText(
                'Android app bypass applies after reconnecting the VPN.',
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: LocalizedText(error.toString())));
      }
    }
  }

  Future<void> _pickWindowsExe() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['exe'],
        dialogTitle: 'Choose an application to bypass the VPN',
      );
      final path = result?.files.single.path;
      if (path == null || path.isEmpty) return;
      final next = LocalCacheService.instance.getWindowsPerAppExecutables();
      if (!next.any((item) => item.toLowerCase() == path.toLowerCase())) {
        next.add(path);
      }
      if (enabled) {
        await WindowsPerAppSplitTunnel.configure(
          enabled: true,
          executables: next,
        );
      }
      await LocalCacheService.instance.saveWindowsPerAppExecutables(next);
      if (!mounted) return;
      setState(() {
        appRules = next
            .map(
              (item) => {
                'desktop_id': item,
                'name': item.split(Platform.pathSeparator).last,
                'mode': 'bypass',
              },
            )
            .toList();
        apps = List<Map<String, dynamic>>.from(appRules);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: LocalizedText('Could not add application: $error')),
      );
    }
  }

  Future<void> _removeWindowsExe(String path) async {
    final next = LocalCacheService.instance
        .getWindowsPerAppExecutables()
        .where((item) => item.toLowerCase() != path.toLowerCase())
        .toList();
    try {
      if (enabled) {
        await WindowsPerAppSplitTunnel.configure(
          enabled: true,
          executables: next,
        );
      }
      await LocalCacheService.instance.saveWindowsPerAppExecutables(next);
      if (!mounted) return;
      setState(() {
        appRules = next
            .map(
              (item) => {
                'desktop_id': item,
                'name': item.split(Platform.pathSeparator).last,
                'mode': 'bypass',
              },
            )
            .toList();
        apps = List<Map<String, dynamic>>.from(appRules);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LocalizedText('Could not remove application: $error'),
        ),
      );
    }
  }

  Future<void> _addRule() async {
    final targetController = TextEditingController();
    String mode = 'bypass';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const LocalizedText('Add split-tunnel CIDR'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: targetController,
                decoration: InputDecoration(
                  labelText: localizedUiText(context, 'CIDR or IP'),
                  hintText: localizedUiText(
                    context,
                    'e.g. 192.168.1.0/24 or 10.0.0.1/32',
                  ),
                ),
              ),
              if (!Platform.isAndroid) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: mode,
                  items: const [
                    DropdownMenuItem(
                      value: 'bypass',
                      child: LocalizedText('Bypass VPN'),
                    ),
                    DropdownMenuItem(
                      value: 'force',
                      child: LocalizedText('Force VPN'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => mode = val);
                  },
                  decoration: InputDecoration(
                    labelText: localizedUiText(context, 'Route action'),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const LocalizedText('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const LocalizedText('Add'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && targetController.text.trim().isNotEmpty) {
      try {
        if (Platform.isAndroid) {
          var target = targetController.text.trim();
          if (!target.contains('/')) {
            target = '$target/${target.contains(':') ? 128 : 32}';
          }
          final cidrs = rules.map((rule) => '${rule['target']}').toSet()
            ..add(target);
          final state = await MobileVpnBridge.setSplitCidrBypass(
            enabled: enabled,
            cidrs: cidrs.toList(),
          );
          if (!mounted) return;
          setState(() {
            rules = (state['cidrs'] as List? ?? cidrs.toList())
                .map((cidr) => {'target': '$cidr', 'mode': 'bypass'})
                .toList();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: LocalizedText(
                'Reconnect the VPN to apply Android CIDR routes.',
              ),
            ),
          );
        } else {
          final state = await controls.addSplitRule(
            targetController.text.trim(),
            mode,
          );
          if (!mounted) return;
          setState(() {
            rules = (state['rules'] as List? ?? const [])
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList();
          });
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: LocalizedText(error.toString())));
        }
      }
    }
  }

  Future<void> _removeRule(String target) async {
    HapticService.lightClick();
    try {
      if (Platform.isAndroid) {
        final cidrs = rules
            .map((rule) => '${rule['target']}')
            .where((cidr) => cidr != target)
            .toList();
        final state = await MobileVpnBridge.setSplitCidrBypass(
          enabled: enabled,
          cidrs: cidrs,
        );
        if (!mounted) return;
        setState(() {
          rules = (state['cidrs'] as List? ?? cidrs)
              .map((cidr) => {'target': '$cidr', 'mode': 'bypass'})
              .toList();
        });
      } else {
        final state = await controls.removeSplitRule(target);
        if (!mounted) return;
        setState(() {
          rules = (state['rules'] as List? ?? const [])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: LocalizedText(error.toString())));
      }
    }
  }

  List<Map<String, dynamic>> get filteredApps {
    return apps.where((app) {
      final name = '${app['name'] ?? ''}'.toLowerCase();
      final id = '${app['desktop_id'] ?? app['package'] ?? ''}'.toLowerCase();
      final matchesQuery = appQuery.isEmpty ||
          name.contains(appQuery.toLowerCase()) ||
          id.contains(appQuery.toLowerCase());
      if (!matchesQuery) return false;

      final isSystem = app['is_system'] == true;
      return switch (filter) {
        SplitAppFilter.all => true,
        SplitAppFilter.user => !isSystem,
        SplitAppFilter.system => isSystem,
      };
    }).toList();
  }

  Widget _buildAppIcon(Map<String, dynamic> app) {
    final rawIcon = app['icon'];
    if (rawIcon is Uint8List && rawIcon.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          rawIcon,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.apps_rounded, size: 22),
        ),
      );
    }

    final pkg = '${app['desktop_id'] ?? app['package']}';
    final cached = LocalCacheService.instance.getCachedAppIcon(pkg);
    if (cached != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          cached,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.apps_rounded, size: 22),
        ),
      );
    }

    final isBypassed = _isAppBypassed(pkg);
    return CircleAvatar(
      backgroundColor: isBypassed
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.apps_outlined,
        color: isBypassed ? Theme.of(context).colorScheme.primary : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFa = Localizations.localeOf(context).languageCode == 'fa';

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (Platform.isWindows) {
      return _buildWindowsSplitTunnelView(context, isFa);
    }

    return Scaffold(
      appBar: AppBar(
        title: LocalizedText(
          isFa ? 'تقسیم ترافیک (Split Tunneling)' : 'Split Tunneling',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    value: enabled,
                    onChanged: isSupported ? _setEnabled : null,
                    title: LocalizedText(
                      isFa
                          ? 'فعال‌سازی Split Tunneling'
                          : 'Enable Split Tunneling',
                    ),
                    subtitle: LocalizedText(
                      isSupported
                          ? (isFa
                              ? 'عبور برنامه‌ها یا آدرس‌های مشخص خارج از تونل امن VPN'
                              : 'Route chosen applications or network subnets outside the VPN.')
                          : (isFa
                              ? 'این قابلیت در پلتفرم فعلی پشتیبانی نمی‌شود.'
                              : 'Not supported on this platform.'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (Platform.isLinux || Platform.isAndroid) ...[
                    LocalizedText(
                      'Network Subnets (CIDRs)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: rules.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: LocalizedText('No CIDR rules yet.'),
                            )
                          : Column(
                              children: [
                                for (final rule in rules)
                                  ListTile(
                                    leading: const Icon(Icons.alt_route),
                                    title: LocalizedText('${rule['target']}'),
                                    subtitle: LocalizedText(
                                      rule['mode'] == 'bypass'
                                          ? 'Bypass VPN'
                                          : 'Force VPN',
                                    ),
                                    trailing: IconButton(
                                      onPressed: () =>
                                          _removeRule('${rule['target']}'),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: enabled && isSupported ? _addRule : null,
                        icon: const Icon(Icons.add),
                        label: const LocalizedText('Add CIDR rule'),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LocalizedText(
                              isFa ? 'برنامه‌ها' : 'Applications',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (appRules.isNotEmpty && !Platform.isLinux)
                              LocalizedText(
                                isFa
                                    ? '${appRules.length} برنامه در لیست استثنا'
                                    : '${appRules.length} app(s) configured for bypass',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed:
                            isSupported ? () => _loadApps(force: true) : null,
                        icon: const Icon(Icons.refresh_rounded),
                        label: LocalizedText(
                          apps.isEmpty
                              ? (isFa ? 'دریافت برنامه‌ها' : 'Load apps')
                              : (isFa ? 'بروزرسانی' : 'Refresh'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LocalizedText(
                    Platform.isLinux
                        ? 'Linux cannot move an already-running app between network routes. Use “Launch direct” to start a separate copy outside the VPN; CIDR rules apply to matching destinations system-wide.'
                        : Platform.isAndroid
                            ? 'Android supports IPv4 and IPv6 CIDR bypass. Reconnect the VPN after changing these routes; app bypass also takes effect after reconnect.'
                            : (isFa
                                ? 'برنامه‌هایی که مایلید ترافیک آن‌ها بدون فیلترشکن و مستقیماً از اینترنت محلی عبور کند را انتخاب کنید.'
                                : (Platform.isWindows
                                    ? 'Windows per-app bypass routes selected apps directly through the physical adapter, independent of the active VPN protocol. Windows build support and the privileged Harmoney service are required.'
                                    : 'Select applications to bypass the VPN tunnel and connect directly to the internet.')),
                  ),
                  const SizedBox(height: 16),
                  // Filter Chips (All / User / System)
                  Row(
                    children: [
                      FilterChip(
                        selected: filter == SplitAppFilter.all,
                        label: LocalizedText(isFa ? 'همه' : 'All'),
                        onSelected: (_) =>
                            setState(() => filter = SplitAppFilter.all),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        selected: filter == SplitAppFilter.user,
                        label: LocalizedText(
                          isFa ? 'برنامه‌های کاربر' : 'User Apps',
                        ),
                        onSelected: (_) =>
                            setState(() => filter = SplitAppFilter.user),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        selected: filter == SplitAppFilter.system,
                        label: LocalizedText(
                          isFa ? 'برنامه‌های سیستم' : 'System Apps',
                        ),
                        onSelected: (_) =>
                            setState(() => filter = SplitAppFilter.system),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SearchBar(
                    hintText: isFa
                        ? localizedUiText(
                            context,
                            'جستجو در نام یا پکیج برنامه‌ها',
                          )
                        : localizedUiText(
                            context,
                            'Search installed apps or packages',
                          ),
                    leading: const Icon(Icons.search),
                    onTap: _loadApps,
                    onChanged: (value) {
                      setState(() => appQuery = value);
                      if (apps.isEmpty) _loadApps();
                    },
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Skeletonizer(
                      enabled: loadingApps,
                      effect: const ShimmerEffect(
                        baseColor: Color(0xFF161B26),
                        highlightColor: Color(0xFF283145),
                      ),
                      child: loadingApps
                          ? Column(
                              children: List.generate(
                                6,
                                (i) => ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.apps),
                                  ),
                                  title: Container(
                                    height: 16,
                                    width: 140,
                                    color: Colors.white,
                                  ),
                                  subtitle: Container(
                                    height: 10,
                                    width: 200,
                                    color: Colors.white,
                                  ),
                                  trailing: Container(
                                    height: 28,
                                    width: 60,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : apps.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: LocalizedText(
                                    isSupported
                                        ? (isFa
                                            ? 'جهت مشاهده و تنظیم استثنا، برنامه‌های نصب‌شده را بارگذاری کنید.'
                                            : 'Load installed applications to configure per-app bypass.')
                                        : 'Per-app bypass is not supported on this platform.',
                                  ),
                                )
                              : Column(
                                  children: [
                                    for (final app
                                        in filteredApps.take(100)) ...[
                                      ListTile(
                                        leading: _buildAppIcon(app),
                                        title: LocalizedText('${app['name']}'),
                                        subtitle: LocalizedText(
                                          _isAppBypassed('${app['desktop_id']}')
                                              ? (isFa
                                                  ? 'خارج از VPN · ${app['desktop_id']}'
                                                  : 'Bypassing VPN · ${app['desktop_id']}')
                                              : '${app['desktop_id']}',
                                        ),
                                        trailing: Wrap(
                                          spacing: 8,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            FilterChip(
                                              selected: _isAppBypassed(
                                                '${app['desktop_id']}',
                                              ),
                                              label: LocalizedText(
                                                _isAppBypassed(
                                                  '${app['desktop_id']}',
                                                )
                                                    ? (isFa
                                                        ? 'در حال گذر'
                                                        : 'Bypassing')
                                                    : (isFa
                                                        ? 'گذر از VPN'
                                                        : 'Bypass'),
                                              ),
                                              onSelected: enabled &&
                                                      !Platform.isLinux
                                                  ? (_) => _toggleAppBypass(app)
                                                  : null,
                                            ),
                                            if (Platform.isLinux)
                                              FilledButton.tonal(
                                                onPressed: enabled
                                                    ? () => _launchDirect(app)
                                                    : null,
                                                child: const LocalizedText(
                                                  'Launch direct',
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const Divider(height: 1),
                                    ],
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWindowsSplitTunnelView(BuildContext context, bool isFa) {
    return Scaffold(
      appBar: AppBar(
        title: LocalizedText(
          isFa ? 'تفکیک ترافیک برنامه‌ها' : 'Per-app VPN bypass',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SwitchListTile(
              value: enabled,
              onChanged: loading ? null : _setEnabled,
              title: LocalizedText(
                isFa ? 'فعال‌سازی بایپس برنامه‌ها' : 'Enable per-app bypass',
              ),
              subtitle: LocalizedText(
                isFa
                    ? 'با مسیریابی بومی ویندوز، برنامه‌های انتخاب‌شده مستقیماً از رابط شبکهٔ فیزیکی عبور می‌کنند. به نسخهٔ سازگار ویندوز و سرویس Harmoney VPN نیاز دارد.'
                    : 'Uses Windows native per-process routing to send selected apps directly over your physical network adapter. Requires a compatible Windows build and the Harmoney VPN service.',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _pickWindowsExe,
              icon: const Icon(Icons.add),
              label: LocalizedText(
                isFa ? 'افزودن فایل اجرایی (.exe)' : 'Add application (.exe)',
              ),
            ),
            const SizedBox(height: 12),
            if (appRules.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: LocalizedText(
                  isFa
                      ? 'هنوز برنامه‌ای انتخاب نشده است.'
                      : 'No applications selected.',
                ),
              )
            else
              for (final app in appRules)
                ListTile(
                  leading: const Icon(Icons.apps_rounded),
                  title: LocalizedText('${app['name']}'),
                  subtitle: LocalizedText(
                    '${app['desktop_id']}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    tooltip: isFa
                        ? localizedUiText(context, 'حذف')
                        : localizedUiText(context, 'Remove'),
                    onPressed: () => _removeWindowsExe('${app['desktop_id']}'),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
            const SizedBox(height: 12),
            LocalizedText(
              isFa
                  ? 'قوانین روی مسیر VPN فعال اعمال می‌شوند. رله UDP هنوز کامل نشده است؛ ممکن است برنامه‌هایی که به UDP نیاز دارند به‌طور کامل از تونل مستثنا نشوند.'
                  : 'Rules apply to the active VPN route. UDP relay is not complete yet; apps requiring UDP may not be fully bypassed.',
            ),
          ],
        ),
      ),
    );
  }
}
