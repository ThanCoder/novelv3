import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/core/types/home_page_list_style_type.dart';
import 'package:novel_v3/other_apps/pdf_reader/pdf_reader.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/fetcher.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:novel_v3/multi_app/multi_app.dart';
import 'package:novel_v3/multi_app/restart_widget.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:t_client/t_client.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';

void main(List<String> args) async {
  if (runWebViewTitleBarWidget(args)) {
    return; // ဒါက window အသစ်တွေအတွက် သီးသန့် အလုပ်လုပ်တာ
  }
  WidgetsFlutterBinding.ensureInitialized();
  // await ThanPkg.instance.init();

  pdfrxInitialize();
  pdfrxFlutterInitialize();

  // Add this your main method.
  // used to show a webview title bar.
  // if (runWebViewTitleBarWidget(args)) {
  //   return;
  // }

  await Setting.instance.init(
    appName: 'NV 3',
    releaseUrl: 'https://github.com/ThanCoder/novelv3/releases',
  );
  final client = TClient();

  await TWidgets.instance.init(
    initialThemeServices: true,
    defaultImageAssetsPath: 'assets/logo_3.jpg',
    getCachePath: (url, cacheName) => PathUtil.getCachePath(name: cacheName),
  );
  await PdfReader.instance.init();

  // recent
  await TRecentDB.getInstance.init(
    rootPath: PathUtil.getConfigPath(name: 'recent.db.json'),
  );
  // set home ui
  homePageListStyleNotifier.value = ListStyleType.getType(
    TRecentDB.getInstance.getString('home_page_list_style'),
  );

  // fetcher
  await Fetcher.instance.init(
    onGetHtmlContent: (url) async {
      final res = await client.get(url);
      return res.data.toString();
    },
  );

  // if (TPlatform.isDesktop) {
  //   WindowOptions windowOptions = WindowOptions(
  //     size: Size(602, 568), // စတင်ဖွင့်တဲ့အချိန် window size

  //     backgroundColor: Colors.transparent,
  //     skipTaskbar: false,
  //     center: false,
  //     title: Setting.instance.appName,
  //   );

  //   windowManager.waitUntilReadyToShow(windowOptions, () async {
  //     await windowManager.show();
  //     // await windowManager.focus();
  //   });
  // }
  runApp(const RestartWidget(child: MultiApp()));
}
