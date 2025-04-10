import 'package:flutter/material.dart';
import 'package:novel_v3/app/screens/app_setting_screen.dart';

import '../components/index.dart';
import '../notifiers/app_notifier.dart';
import '../services/index.dart';
import '/app/widgets/index.dart';

class AppMorePage extends StatelessWidget {
  const AppMorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: Text('More'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //theme
            ListTileWithDesc(
              leading: Icon(Icons.dark_mode_outlined),
              title: 'Dark Theme',
              trailing: ValueListenableBuilder(
                valueListenable: isDarkThemeNotifier,
                builder: (context, isDark, child) => Checkbox(
                  value: isDark,
                  onChanged: (value) {
                    isDarkThemeNotifier.value = value!;
                    //set config
                    appConfigNotifier.value.isDarkTheme = value;
                    setConfigFile(appConfigNotifier.value);
                  },
                ),
              ),
            ),
            //version
            ListTileWithDesc(
              leading: Icon(Icons.settings),
              title: 'Setting',
              trailing: Icon(Icons.arrow_forward_ios_rounded),
              onClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppSettingScreen(),
                  ),
                );
              },
            ),
            //Clean Cache
            const CacheComponent(),

            //version
            const Divider(),
            
          ],
        ),
      ),
    );
  }
}
