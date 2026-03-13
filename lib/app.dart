import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class AsherAdventureApp extends StatelessWidget {
  const AsherAdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Asher's Adventure",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
