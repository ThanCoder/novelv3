import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/bloc_app.dart';
import 'package:novel_v3/core/databases/chapter_db.dart';
import 'package:novel_v3/core/types/home_page_list_style_type.dart';
import 'package:novel_v3/core/providers/novel_provider.dart';
import 'package:novel_v3/app/others/pdf_reader/pdf_reader.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/fetcher.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:t_client/t_client.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:novel_v3/app/my_app.dart';
import 'package:novel_v3/more_libs/desktop_exe/desktop_exe.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';

void main() async {
  await ThanPkg.instance.init();
  final novelProvider = NovelProvider();

  await Setting.instance.init(
    appName: 'NV 3',
    releaseUrl: 'https://github.com/ThanCoder/novelv3/releases',
    onSettingSaved: (context, message) {
      showTSnackBar(context, message);
      novelProvider.init(isUsedCache: false);
    },
  );
  final client = TClient();

  await TWidgets.instance.init(
    initialThemeServices: true,
    defaultImageAssetsPath: 'assets/logo_3.jpg',
    isDarkTheme: () => Setting.getAppConfig.isDarkTheme,
    getCachePath: (url) => PathUtil.getCachePath(
      name: '${url.split('/').last.replaceAll(':', '-')}.png',
    ),
    onDownloadImage: (url, savePath) async {
      await client.download(url, savePath: savePath);
    },
  );
  await PdfReader.instance.init(
    getDarkTheme: () => Setting.getAppConfig.isDarkTheme,
  );
  // chapter db
  ChapterDB.setAdapters();

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

  if (TPlatform.isDesktop) {
    await DesktopExe.exportDesktopIcon(
      name: Setting.instance.appName,
      assetsIconPath: 'assets/logo_3.jpg',
    );

    WindowOptions windowOptions = WindowOptions(
      size: Size(602, 568), // စတင်ဖွင့်တဲ့အချိန် window size

      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      center: false,
      title: Setting.instance.appName,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      // await windowManager.focus();
    });
  }
  runApp(const MyApp());
}
