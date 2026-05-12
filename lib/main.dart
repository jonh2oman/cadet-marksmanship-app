import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/routing/app_router.dart';
import 'src/theme/app_theme.dart';

import 'src/shared/providers/theme_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeProvider);

    ThemeData getTheme() {
      switch (themeMode) {
        case AppThemeMode.light:
          return AppTheme.lightTheme;
        case AppThemeMode.dark:
          return AppTheme.darkTheme;
        case AppThemeMode.sea:
          return AppTheme.seaTheme;
        case AppThemeMode.system:
          return AppTheme.darkTheme; // Fallback or handle system
      }
    }

    return MaterialApp.router(
      title: 'Marksmanship Tool',
      theme: AppTheme.lightTheme,
      darkTheme: themeMode == AppThemeMode.sea ? AppTheme.seaTheme : AppTheme.darkTheme,
      themeMode: themeMode.toThemeMode,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
