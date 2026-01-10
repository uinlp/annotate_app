import 'package:flutter/material.dart';
import 'package:uinlp_annotate/utilities/router.dart';
import 'package:uinlp_annotate/utilities/theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UINLP Annotate',
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
