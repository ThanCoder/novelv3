import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/my_app.dart';
import 'package:novel_v3/my_libs/pdf_readers_v1.0.1/pdf_reader.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import 'app/services/index.dart';
import 'app/setting/app_notifier.dart';
import 'my_libs/app_helpers/app_help_button.dart';
import 'my_libs/novel_dir_db/novel_dir_db.dart';
import 'my_libs/novel_v3_uploader_v1.3.0/novel_v3_uploader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ThanPkg.instance.init();
  await TWidgets.instance.init(
    defaultImageAssetsPath: 'assets/cover.png',
    getDarkMode: () => appConfigNotifier.value.isDarkTheme,
  );
  await PdfReader.instance.init(
    getDarkTheme: () => appConfigNotifier.value.isDarkTheme,
    showMessage: (context, msg) {
      showTSnackBar(context, msg);
    },
  );

  //init config
  await initAppConfigService();
  // await GeneralServices.instance.init();
  // THistoryServices.instance
  //     .init('${PathUtil.getCachePath()}/t_history_record.json');
  //static server
  await NovelV3Uploader.instance.init(
      isShowDebugLog: true,
      onDownloadJson: (url) async {
        final res = await Dio().get(url);
        return res.data.toString();
      },
      appBarActions: [AppHelpButton()]);
  // local novel
  await NovelDirDb.instance.init(
    getAppCachePath: () => '',
    getRootDirPath: () => '/home/than/.novel_v3',
    onPdfReader: (context, pdf) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfrxReaderScreen(
              pdfConfig: PdfConfigModel.fromPath(pdf.getConfigPath),
              sourcePath: pdf.path,
              title: pdf.getTitle,
              onConfigUpdated: (pdfConfig) {
                pdfConfig.savePath(pdf.getConfigPath);
              },
            ),
          ));
    },
  );

  runApp(
    // const ProviderScope(
    //   child: MyApp(),
    // ),
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
