import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';

import 'app_notifier.dart';

class ThemeComponent extends StatelessWidget {
  const ThemeComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appConfigNotifier,
      builder: (context, config, child) {
        return TListTileWithDesc(
          title: 'Dark Mode',
          trailing: Checkbox.adaptive(
            value: config.isDarkTheme,
            onChanged: (value) {
              appConfigNotifier.value =
                  appConfigNotifier.value.copyWith(isDarkTheme: value);
              appConfigNotifier.value.save();
            },
          ),
        );
      },
    );
  }
}
