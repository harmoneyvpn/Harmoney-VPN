import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/vpn_debug_log_service.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

class VpnDebugLogSheet extends StatefulWidget {
  const VpnDebugLogSheet({super.key});

  @override
  State<VpnDebugLogSheet> createState() => _VpnDebugLogSheetState();
}

class _VpnDebugLogSheetState extends State<VpnDebugLogSheet> {
  final _service = VpnDebugLogService.instance;
  final _filterController = TextEditingController();
  final _lines = <VpnDebugLogEntry>[];
  StreamSubscription<VpnDebugLogEntry>? _subscription;
  String _filter = '';
  String _level = 'ALL';

  @override
  void initState() {
    super.initState();
    _lines.addAll(_service.entries);
    _subscription = _service.events.listen((entry) {
      if (mounted) setState(() => _lines.add(entry));
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _filterController.dispose();
    super.dispose();
  }

  List<VpnDebugLogEntry> get _visibleLines {
    final query = _filter.trim().toLowerCase();
    return _lines.where((entry) {
      if (_level != 'ALL' && entry.level != _level) return false;
      return query.isEmpty || entry.toString().toLowerCase().contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleLines;
    final text = visible.map((entry) => entry.toString()).join('\n');
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.84,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.bug_report_outlined),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: LocalizedText(
                      'VPN Debug Logs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: localizedUiText(context, 'Copy visible logs'),
                    onPressed: text.isEmpty
                        ? null
                        : () => Clipboard.setData(ClipboardData(text: text)),
                    icon: const Icon(Icons.copy),
                  ),
                  IconButton(
                    tooltip: localizedUiText(context, 'Clear logs'),
                    onPressed: () => setState(() {
                      _service.clear();
                      _lines.clear();
                    }),
                    icon: const Icon(Icons.delete_outline),
                  ),
                  IconButton(
                    tooltip: localizedUiText(context, 'Close'),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const LocalizedText(
                'Live connection events from all providers and protocols',
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: [
                  for (final level in const ['ALL', 'INFO', 'WARNING', 'ERROR'])
                    ChoiceChip(
                      label: LocalizedText(level),
                      selected: _level == level,
                      onSelected: (_) => setState(() => _level = level),
                    ),
                ],
              ),
              TextField(
                controller: _filterController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: localizedUiText(
                    context,
                    'Filter by provider, protocol, status, or error',
                  ),
                  isDense: true,
                ),
                onChanged: (value) => setState(() => _filter = value),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: visible.isEmpty
                      ? const Center(
                          child: LocalizedText(
                            'No matching events yet. Start a VPN connection to collect logs.',
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: visible.length,
                          padding: const EdgeInsets.all(10),
                          itemBuilder: (context, index) {
                            final entry = visible[visible.length - 1 - index];
                            final color = switch (entry.level) {
                              'ERROR' => Colors.redAccent,
                              'WARNING' => Colors.orangeAccent,
                              _ => Colors.greenAccent,
                            };
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: SelectableText(
                                entry.toString(),
                                style: TextStyle(
                                  color: color,
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
