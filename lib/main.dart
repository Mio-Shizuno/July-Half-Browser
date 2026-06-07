import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/browser_state.dart';
import 'screens/browser_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 沉浸式状态栏
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0000),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // 强制竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => BrowserState(),
      child: const HellBrowserApp(),
    ),
  );
}

class HellBrowserApp extends StatelessWidget {
  const HellBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '柒月半浏览器',
      debugShowCheckedModeBanner: false,
      theme: HellTheme.theme,
      home: const BrowserScreen(),
    );
  }
}