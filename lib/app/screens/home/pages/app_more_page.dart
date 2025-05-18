import 'package:flutter/material.dart';
import 'package:novel_v3/app/my_libs/general_server/current_version_component.dart';
import 'package:novel_v3/app/screens/app_setting_screen.dart';
import 'package:novel_v3/app/my_libs/novel_data/novel_data_scanner_screen.dart';
import 'package:novel_v3/app/screens/pdf_scanner_screen.dart';
import 'package:novel_v3/app/my_libs/share/share_home_screen.dart';
import 'package:t_widgets/t_widgets.dart';

import '../../../components/index.dart';
import '../../../notifiers/app_notifier.dart';
import '../../../services/index.dart';

class AppMorePage extends StatelessWidget {
  const AppMorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //theme
            TListTileWithDesc(
              leading: const Icon(Icons.dark_mode_outlined),
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
            TListTileWithDesc(
              leading: const Icon(Icons.settings),
              title: 'Setting',
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppSettingScreen(),
                  ),
                );
              },
            ),
            // version
            const CurrentVersionComponent(),
            //Clean Cache
            const CacheComponent(),
            const Divider(),
            //pdf scanner
            TListTileWithDesc(
              title: 'PDF Scanner',
              desc: 'PDF Files အားလုံးကို Scan လုပ်ပေးသည်',
              onClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfScannerScreen(),
                  ),
                );
              },
            ),

            //novel data scanner
            TListTileWithDesc(
              title: 'Data Scanner',
              desc: 'Data Files အားလုံးကို Scan လုပ်ပေးသည်',
              onClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NovelDataScannerScreen(),
                  ),
                );
              },
            ),

            //novel data Share
            TListTileWithDesc(
              title: 'Share',
              desc: 'Data Files အားလုံးကို မျှဝေးပေးသည်',
              onClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShareHomeScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
