import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/my_app.dart';
import 'package:novel_v3/app/providers/novel_bookmark_provider.dart';
import 'package:novel_v3/more_libs/desktop_exe/desktop_exe.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/fetcher.dart';
import 'package:novel_v3/more_libs/general_static_server/constants.dart';
import 'package:novel_v3/more_libs/general_static_server/general_server.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/constants.dart';
import 'package:novel_v3/more_libs/pdf_readers_v1.2.3/pdf_reader.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import 'app/ui/novel_dir_app.dart';
import 'more_libs/novel_v3_uploader_v1.3.0/novel_v3_uploader.dart'
    hide NovelServices;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // call theme
  ThemeServices.instance.init();

  await Setting.instance.initSetting(
    appName: 'novel_v3',
    versionLable: 'Novel V3',
    onShowMessage: (context, message) {
      showTSnackBar(context, message);
    },
    onDatabasePathChanged: () {
      NovelServices.clearCache();
    },
  );

  await ThanPkg.instance.init();

  final dio = Dio();

  await TWidgets.instance.init(
    defaultImageAssetsPath: 'assets/logo_2.jpg',
    getDarkMode: () => Setting.getAppConfig.isDarkMode,
    onDownloadImage: (url, savePath) async {
      await dio.download(url, savePath);
    },
  );
  await PdfReader.instance.init(
    getDarkTheme: () => Setting.getAppConfig.isDarkMode,
    showMessage: (context, msg) {
      showTSnackBar(context, msg);
    },
  );
  //static server
  await NovelV3Uploader.instance.init(
    isShowDebugLog: true,
    getContentFromUrl: (url) async {
      final res = await dio.get(url);
      return res.data.toString();
    },
    appBarActions: [],
    getLocalServerPath: () => '',
    getApiServerUrl: () => serverGitubRootUrl,
  );
  // general static server
  await GeneralServer.instance.init(
    getApiServerUrl: () => apiServerUrl,
    getLocalServerPath: () => localServerPath,
    getContentFromUrl: (url) async {
      final res = await dio.get(url);
      return res.data.toString();
    },
  );

  // local novel
  await NovelDirApp.instance.init(
    getAppCachePath: () => PathUtil.getCachePath(),
    getRootDirPath: () => Setting.appRootPath,
    onGetN3DataPassword: () => NovelDirApp.getSecretKey,
    onShowMessage: (context, message) {
      showTSnackBar(context, message);
    },
  );
  // fetcher
  await Fetcher.instance.init(
    onGetHtmlContent: (url) async {
      final res = await dio.get(url);
      return res.data.toString();
    },
    onShowErrorMessage: (context, message) {
      showTMessageDialogError(context, message);
    },
  );
  await DesktopExe.instance.exportNotExists(
    name: 'Novel',
    assetsIconPath: 'assets/logo_2.jpg',
  );

  if (TPlatform.isDesktop) {
    WindowOptions windowOptions = const WindowOptions(
      size: Size(602, 568), // စတင်ဖွင့်တဲ့အချိန် window size

      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      center: false,
      title: "Novel V3",
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // ကြိုခေါ်ထာခြင်း
  PdfServices.initRecentDB();
  //share recent
  await TRecentDB.getInstance.init(
    rootPath: PathUtil.getConfigPath(name: 'share-recent.db.json'),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NovelProvider()),
        ChangeNotifierProvider(create: (context) => NovelBookmarkProvider()),
        ChangeNotifierProvider(create: (context) => ChapterProvider()),
        ChangeNotifierProvider(create: (context) => PdfProvider()),
      ],
      child: MyApp(),
    ),
  );
}
