import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets_dev.dart';

class ThemeListener extends StatelessWidget {
  final Widget Function(BuildContext context, ThemeMode themeMode) builder;
  const ThemeListener({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Setting.getAppConfigNotifier,
      builder: (context, config, child) {
        if (config.themeMode == TThemeModes.system) {
          return ThemeModeListener(builder: builder);
        }
        if (config.themeMode == TThemeModes.dark) {
          return builder(context, ThemeMode.dark);
        }
        return builder(context, ThemeMode.light);
      },
    );
  }
}
