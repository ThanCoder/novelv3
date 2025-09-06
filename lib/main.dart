import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/my_app.dart';
import 'package:novel_v3/app/providers/novel_bookmark_provider.dart';
import 'package:novel_v3/more_libs/desktop_exe/desktop_exe.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/fetcher.dart';
import 'package:novel_v3/more_libs/pdf_readers_v1.1.2/pdf_reader.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import 'more_libs/app_helpers/app_help_button.dart';
import 'app/novel_dir_app.dart';
import 'more_libs/novel_v3_uploader_v1.3.0/novel_v3_uploader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Setting.instance.initSetting(
    appName: 'novel_v3',
    versionLable: 'Novel V3 (Stable Release)',
  );

  await ThanPkg.instance.init();

  final dio = Dio();

  await TWidgets.instance.init(
    defaultImageAssetsPath: 'assets/cover.png',
    getDarkMode: () => Setting.getAppConfig.isDarkTheme,
    onDownloadImage: (url, savePath) async {
      await dio.download(url, savePath);
    },
  );
  await PdfReader.instance.init(
    getDarkTheme: () => Setting.getAppConfig.isDarkTheme,
    showMessage: (context, msg) {
      showTSnackBar(context, msg);
    },
  );
  //static server
  await NovelV3Uploader.instance.init(
    isShowDebugLog: true,
    onDownloadJson: (url) async {
      final res = await dio.get(url);
      return res.data.toString();
    },
    appBarActions: [AppHelpButton()],
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
    assetsIconPath: 'assets/cover.png',
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
