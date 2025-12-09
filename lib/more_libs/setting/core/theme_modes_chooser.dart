import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/setting/app_config.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ThemeModesChooser extends StatefulWidget {
  const ThemeModesChooser({super.key});

  @override
  State<ThemeModesChooser> createState() => _ThemeModesChooserState();
}

class _ThemeModesChooserState extends State<ThemeModesChooser> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.color_lens),
            Text(
              'Theme',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            ValueListenableBuilder(
              valueListenable: Setting.getAppConfigNotifier,
              builder: (context, config, child) {
                return DropdownButton<ThemeMode>(
                  padding: EdgeInsets.all(5),
                  borderRadius: BorderRadius.circular(4),
                  value: config.themeMode,
                  items: ThemeMode.values
                      .map(
                        (e) => DropdownMenuItem<ThemeMode>(
                          value: e,
                          child: Text(e.name.toCaptalize()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) async {
                    final newConfig = config.copyWith(
                      themeMode: value,
                      isDarkTheme: value!.isDarkTheme,
                    );
                    Setting.getAppConfigNotifier.value = newConfig;
                    await newConfig.save();
                    if (newConfig.themeMode == ThemeMode.system) {
                      PBrightnessServices.instance.checkCurrentTheme();
                    }
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              },
            ),
            SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}
