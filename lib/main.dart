import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/my_app.dart';
import 'package:novel_v3/more_libs/pdf_readers_v1.0.1/pdf_reader.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import 'more_libs/app_helpers/app_help_button.dart';
import 'app/novel_dir_app.dart';
import 'more_libs/novel_v3_uploader_v1.3.0/novel_v3_uploader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Setting.instance.initSetting(appName: 'novel_v3');

  await ThanPkg.instance.init();
  await TWidgets.instance.init(
    defaultImageAssetsPath: 'assets/cover.png',
    getDarkMode: () => Setting.getAppConfig.isDarkTheme,
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
        final res = await Dio().get(url);
        return res.data.toString();
      },
      appBarActions: [AppHelpButton()]);
  // local novel
  await NovelDirApp.instance.init(
    getAppCachePath: () => PathUtil.getCachePath(),
    getRootDirPath: () => Setting.appRootPath,
    onShowMessage: (context, message) {
      showTSnackBar(context, message);
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NovelProvider()),
        ChangeNotifierProvider(create: (context) => ChapterProvider()),
        ChangeNotifierProvider(create: (context) => PdfProvider()),
      ],
      child: MyApp(),
    ),
  );
}
