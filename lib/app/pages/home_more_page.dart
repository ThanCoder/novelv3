import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/screens/novel_screens/novel_data_scanner_screen.dart';
import 'package:novel_v3/app/screens/novel_screens/novel_mc_search_screen.dart';
import 'package:novel_v3/app/screens/pdf_screens/pdf_scanner_screen.dart';
import 'package:novel_v3/app/screens/setting_screen.dart';
import 'package:novel_v3/app/screens/share/receive_novel_data_screen.dart';
import 'package:novel_v3/app/screens/share/share_novel_data_screen.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:novel_v3/app/widgets/list_tile_with_desc.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeMorePage extends StatefulWidget {
  const HomeMorePage({super.key});

  @override
  State<HomeMorePage> createState() => _HomeMorePageState();
}

class _HomeMorePageState extends State<HomeMorePage> {
  @override
  void initState() {
    init();
    super.initState();
  }

  String appVersion = '';

  void init() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      setState(() {
        appVersion = packageInfo.version;
      });
    } catch (e) {
      debugPrint('HomeDrawer:init ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 10,
          children: [
            //theme
            ListTileWithDesc(
              leading: const Icon(Icons.dark_mode_outlined),
              title: 'Dark Theme',
              trailing: Checkbox(
                value: appConfigNotifier.value.isDarkTheme,
                onChanged: (value) {
                  appConfigNotifier.value.isDarkTheme = value!;
                  isDarkThemeNotifier.value = value;
                  setState(() {});
                  setConfigFile(appConfigNotifier.value);
                  CherryToast.success(
                    inheritThemeColors: true,
                    title: const Text('Setting သိမ်းပြီးပါပြီ'),
                  ).show(context);
                },
              ),
            ),
            const Divider(),
            const Text('Offline Function'),
            //PDF Scanner
            ListTileWithDesc(
              leading: const Icon(Icons.picture_as_pdf_rounded),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              title: 'PDF Scanner',
              desc: 'PDF Files တွေကို ရှာပေးတယ်',
              onClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PdfScannerScreen(),
                  ),
                );
              },
            ),
            //Data Scanner
            ListTileWithDesc(
              leading: const Icon(Icons.restore),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              title: 'Data Scanner',
              desc: 'Novel Data သွင်းလို့ရတယ်',
              onClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NovelDataScannerScreen(),
                  ),
                );
              },
            ),
            //Main Character (MC)
            ListTileWithDesc(
              leading: const Icon(Icons.person_2),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              title: 'Main Character (MC)',
              desc: 'အထိက ဇော်ကောင်ကို ရှာဖွေခြင်း',
              onClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NovelMcSearchScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            const Text('Data Sharing'),
            //novel data share
            ListTileWithDesc(
              onClick: () {
                //မျှဝေမယ်
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShareNovelDataScreen(),
                  ),
                );
              },
              leading: const Icon(Icons.share_outlined),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              title: 'Share Data',
              desc: 'Novel အခြားသူတွေကို မျှဝေခြင်း',
            ),
            //receive novel data
            ListTileWithDesc(
              onClick: () {
                //လက်ခံမယ်
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReceiveNovelDataScreen(),
                  ),
                );
              },
              leading: const Icon(Icons.cloud_download_rounded),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              title: 'Share Data',
              desc: 'Novel အခြားသူတွေကနေ လက်ခံခြင်း',
            ),
            const Divider(),
            //settting
            ListTileWithDesc(
              onClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingScreen(),
                  ),
                );
              },
              leading: const Icon(Icons.settings),
              title: 'Setting',
            ),
            ListTileWithDesc(
              leading: const Icon(Icons.cloud_upload_rounded),
              title: 'App Version',
              desc: 'Current Version: $appVersion ($appVersionName)',
              onClick: () {
                CherryToast.success(
                  inheritThemeColors: true,
                  title: const Text('မပြုလုပ်ရသေးပါ'),
                ).show(context);
              },
            ),
            //about
            ListTileWithDesc(
              title: 'About',
              onClick: () {
                showAboutDialog(
                    context: context,
                    applicationName: appName,
                    applicationVersion: appVersion,
                    children: const [
                      Text('Developer: ThanCoder'),
                    ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
