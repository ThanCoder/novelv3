import 'package:flutter/material.dart';
import 'package:novel_v3/app/ui/get_start/getstart_screen.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:t_server/core/t_server.dart';
import 'package:than_pkg/than_pkg.dart';

import 'ui/home_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    TServer.instance.stop(force: true);
    TServer.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readGetstart = TRecentDB.getInstance.getBool('read-getstart');
    return ThemeSwitcher(
      builder: (config) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: config.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: readGetstart
              ? const HomeScreen()
              : GetstartScreen(child: HomeScreen()),
        );
      },
    );
  }
}
