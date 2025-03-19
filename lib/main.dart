import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:novel_v3/app/my_app.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:than_pkg/than_pkg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final url = dotenv.env['SUPABASE_URL'];
  final key = dotenv.env['SUPABASE_ANON_KEY'];
  if (key != null && url != null) {
    await Supabase.initialize(
      url: url,
      anonKey: key,
    );
  }

  await ThanPkg.windowManagerensureInitialized();

  //init config
  await initAppConfigService();
  await ReleaseServices.instance.initReleaseService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NovelProvider()),
        ChangeNotifierProvider(create: (context) => ChapterProvider()),
        ChangeNotifierProvider(create: (context) => PdfProvider()),
        ChangeNotifierProvider(create: (context) => OnlineNovelProvider()),
        ChangeNotifierProvider(create: (context) => ChapterBookmarkProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
