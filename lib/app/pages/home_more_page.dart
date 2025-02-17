import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/screens/novel_data_scanner_screen.dart';
import 'package:novel_v3/app/screens/pdf_scanner_screen.dart';
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
            ListTileWithDesc(
              leadingIcon: const Icon(Icons.dark_mode_outlined),
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
            ListTileWithDesc(
              leadingIcon: const Icon(Icons.picture_as_pdf_rounded),
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
            ListTileWithDesc(
              leadingIcon: const Icon(Icons.restore),
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
            ListTileWithDesc(
              leadingIcon: const Icon(Icons.download_for_offline_outlined),
              title: 'App Version',
              desc: 'Version: $appVersion ($appVersionName)',
              onClick: () {
                CherryToast.success(
                  inheritThemeColors: true,
                  title: const Text('မပြုလုပ်ရသေးပါ'),
                ).show(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
