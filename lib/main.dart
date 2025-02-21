import 'package:flutter/material.dart';
import 'package:novel_v3/app/my_app.dart';
import 'package:novel_v3/app/provider/chapter_provider.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/provider/pdf_provider.dart';
import 'package:novel_v3/app/utils/config_util.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //url
  // const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  // const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // await Supabase.initialize(
  //   url: supabaseUrl,
  //   anonKey: supabaseKey,
  // );

  //init config
  await initConfig();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NovelProvider()),
        ChangeNotifierProvider(create: (context) => ChapterProvider()),
        ChangeNotifierProvider(create: (context) => PdfProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
