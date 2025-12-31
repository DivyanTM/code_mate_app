import 'package:flutter/material.dart';
import 'package:code_mate/ui/theme/app_theme.dart';
import 'package:code_mate/ui/pages/login_page.dart';
import 'package:code_mate/ui/pages/url_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Code Mate',
      theme: AppTheme.blueLightTheme,
      darkTheme: AppTheme.blueDarkTheme,
      themeMode: ThemeMode.system,
      home:  BackendUrlScreen(),
    );
  }
}
