// import 'package:code_mate/ui/pages/url_page.dart';
import 'package:code_mate/data/sources/global_state.dart';
import 'package:code_mate/ui/pages/home_screen.dart';
import 'package:code_mate/ui/pages/login_page.dart';
import 'package:code_mate/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GlobalState().loadPrefs();

  runApp(const ProviderScope(child: MyApp()));
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
      home: GlobalState().loggedIn ? DiscoveryHomeScreen() : LoginScreen(),
    );
  }
}
