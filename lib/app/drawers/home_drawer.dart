import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/screens/share/receive_novel_data_screen.dart';
import 'package:novel_v3/app/screens/setting_screen.dart';
import 'package:novel_v3/app/screens/share/share_novel_data_screen.dart';
import 'package:novel_v3/app/widgets/my_image_file.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
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

  void goSharePage() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText:
            'သင်က လက်ခံမှာလား?။ (Receive)\nဒါမဟုတ် မျှဝေပေးမှာလား?။ (Share)',
        submitText: 'လက်ခံမယ်(Receive)',
        cancelText: 'မျှဝေမယ်(Share)',
        onSubmit: () {
          //လက်ခံမယ်
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReceiveNovelDataScreen(),
            ),
          );
        },
        onCancel: () {
          //မျှဝေမယ်
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ShareNovelDataScreen(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const SizedBox(height: 10),
          const Center(child: Text(appTitle)),
          DrawerHeader(
            child: MyImageFile(path: ''),
          ),
          //share novel
          ListTile(
            onTap: () {
              Navigator.pop(context);
              goSharePage();
            },
            leading: const Icon(Icons.share_outlined),
            title: const Text('Share Data'),
          ),
          //settting
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingScreen(),
                ),
              );
            },
            leading: const Icon(Icons.settings),
            title: const Text('Setting'),
          ),

          const SizedBox(height: 30),
          //bottom
          ListTile(
            leading: const Icon(Icons.info),
            title: Text('Version: $appVersion ($appVersionName)'),
          ),
        ],
      ),
    );
  }
}
