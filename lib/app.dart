import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/shell/home_shell.dart';
import 'theme/app_theme.dart';

class DailyRoutineApp extends StatelessWidget {
  const DailyRoutineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Daily Routine',
        theme: AppTheme.light(),
        home: const HomeShell(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
