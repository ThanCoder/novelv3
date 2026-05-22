import 'package:cf_lite/cf_lite.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:novel_v3/other_apps/share/libs/share_receive_url_form_dialog.dart';
import 'package:novel_v3/other_apps/share/receive/novel_receive_home_screen.dart';
import 'package:novel_v3/other_apps/share/send/novel_share_screen.dart';
import 'package:novel_v3/other_apps/share/server_services.dart';
import 'package:t_widgets/t_widgets.dart';

class ShareHomeScreen extends StatefulWidget {
  const ShareHomeScreen({super.key});

  @override
  State<ShareHomeScreen> createState() => _ShareHomeScreenState();
}

class _ShareHomeScreenState extends State<ShareHomeScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    try {
      await ServerServices.getInstance.server.stop(force: true);
      await ServerServices.getInstance.server.start(
        '0.0.0.0',
        4545,
        shared: true,
      );
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return TScaffold(
      appBar: AppBar(title: Text('Novel မျှဝေးခြင်း')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 15,
          children: [
            ElevatedButton(
              onPressed: () {
                context.goRoute(builder: (context) => NovelShareScreen());
              },
              child: Column(
                children: [Icon(Icons.share, size: 70), Text('မျှဝေမယ်')],
              ),
            ),

            ElevatedButton(
              onPressed: _goReceiveScreen,
              child: Column(
                children: [
                  Icon(Icons.cloud_download_rounded, size: 70),
                  Text('လက်ခံမယ်'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goReceiveScreen() async {
    String key = 'share-host-address';
    final url = CFLite.getInstance().getString(key);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ShareReceiveUrlFormDialog(
        recentUrl: url,
        onConnectedUrl: (connectedUrl) {
          CFLite.getInstance().put(key, connectedUrl);
        },
        onSuccess: (url) {
          context.goRoute(
            builder: (context) => NovelReceiveHomeScreen(hostUrl: url),
          );
        },
      ),
    );
  }
}
