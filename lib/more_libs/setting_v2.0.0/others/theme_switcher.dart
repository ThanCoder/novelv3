import 'dart:async';

import 'package:flutter/material.dart';

import '../app_config.dart';
import '../setting.dart';

class ThemeSwitcher extends StatefulWidget {
  final Widget Function(AppConfig config) builder;
  const ThemeSwitcher({super.key, required this.builder});

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  late StreamSubscription<ThemeModes> _themeSub;

  @override
  void initState() {
    _themeSub = ThemeServices.instance.onBrightnessChanged.listen((data) {
      final oldConfig = Setting.getAppConfigNotifier.value;
      if (oldConfig.themeMode == ThemeModes.system &&
          oldConfig.isDarkMode != data.isDarkMode) {
        final newConfig = Setting.getAppConfigNotifier.value.copyWith(
          isDarkMode: data.isDarkMode,
        );
        Setting.getAppConfigNotifier.value = newConfig;
      }
    });
    ThemeServices.instance.check();

    super.initState();
  }

  @override
  void dispose() {
    _themeSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Setting.getAppConfigNotifier,
      builder: (context, config, child) {
        return widget.builder(config);
      },
    );
  }
}
