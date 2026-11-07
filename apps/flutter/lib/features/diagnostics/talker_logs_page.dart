import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../core/app_talker.dart';

class TalkerLogsPage extends StatelessWidget {
  const TalkerLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isFa = Localizations.localeOf(context).languageCode == 'fa';

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D111A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF131824),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      child: TalkerScreen(
        talker: AppTalker.instance,
        theme: const TalkerScreenTheme(
          backgroundColor: Color(0xFF0D111A),
          cardColor: Color(0xFF171D2B),
          textColor: Colors.white,
        ),
        appBarTitle:
            isFa ? 'لاگ‌های فنی و کنسول دیباگ' : 'Technical Logs & Diagnostics',
      ),
    );
  }
}
