import 'dart:async';

import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:flutter/material.dart';

class ThemeListener extends StatefulWidget {
  final Widget Function(BuildContext context, ThemeMode themeMode) builder;
  const ThemeListener({super.key, required this.builder});

  @override
  State<ThemeListener> createState() => _ThemeListenerState();
}

class _ThemeListenerState extends State<ThemeListener> {
  late StreamSubscription<Brightness> _streamSubscription;
  @override
  void initState() {
    init(PBrightnessServices.instance.currentBrightness);
    _streamSubscription = PBrightnessServices.instance.onBrightnessChanged
        .listen(init);
    PBrightnessServices.instance.init();
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  void init(Brightness brightness) {
    final config = Setting.getAppConfig;
    if (config.themeMode == ThemeMode.system) {
      Setting.getAppConfigNotifier.value = config.copyWith(
        isDarkTheme: brightness.isDark,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Setting.getAppConfigNotifier,
      builder: (context, config, child) {
        return widget.builder(
          context,
          config.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}
