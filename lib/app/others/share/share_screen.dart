import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/share/libs/share_receive_url_form_dialog.dart';
import 'package:novel_v3/app/others/share/novel_receive_screen.dart';
import 'package:novel_v3/app/others/share/novel_share_screen.dart';
import 'package:novel_v3/more_libs/json_database_v1.0.0/recent_db.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/routes_helper.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';
import 'package:t_server/t_server.dart';
import 'package:t_widgets/t_widgets.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    try {
      TServer.instance.startListen(port: 4545);
    } catch (e) {
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
                goRoute(context, builder: (context) => NovelShareScreen());
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
    final pre = await RecentDB.getInstance(
      dbPath: PathUtil.getCachePath(name: 'share-recent.db.json'),
    );
    String key = 'share-host-address';
    String url = pre.getString(key);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ShareReceiveUrlFormDialog(
        recentUrl: url,
        onConnectedUrl: (connectedUrl) {
          pre.setString(key, connectedUrl);
        },
        onSuccess: (url) {
          goRoute(context, builder: (context) => NovelReceiveScreen(url: url));
        },
      ),
    );
  }
}
