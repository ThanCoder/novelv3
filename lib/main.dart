import 'package:flutter/material.dart';
import 'package:novel_v3/app/general_server/index.dart';
import 'package:novel_v3/app/my_app.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:provider/provider.dart';
import 'package:than_pkg/than_pkg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await ThanPkg.windowManagerensureInitialized();

  //init config
  await initAppConfigService();
  await GeneralServices.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NovelProvider()),
        ChangeNotifierProvider(create: (context) => ChapterProvider()),
        ChangeNotifierProvider(create: (context) => PdfProvider()),
        ChangeNotifierProvider(create: (context) => ChapterBookmarkProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
