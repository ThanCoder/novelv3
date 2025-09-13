import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:t_server/core/t_server.dart';

import 'home_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ThemeModes> _themeSub;

  @override
  void initState() {
    _themeSub = ThemeServices().onBrightnessChanged.listen((data) {
      final oldConfig = Setting.getAppConfigNotifier.value;
      if (oldConfig.themeMode == ThemeModes.system &&
          oldConfig.isDarkMode != data.isDarkMode) {
        final newConfig = Setting.getAppConfigNotifier.value.copyWith(
          isDarkMode: data.isDarkMode,
        );
        Setting.getAppConfigNotifier.value = newConfig;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    TServer.instance.stop(force: true);
    TServer.instance.dispose();
    _themeSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Setting.getAppConfigNotifier,
      builder: (context, config, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: config.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}
