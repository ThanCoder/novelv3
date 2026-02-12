import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_provider.dart';
import 'package:novel_v3/app/ui/home/home_screen.dart';
import 'package:novel_v3/core/providers/novel_provider.dart';
import 'package:novel_v3/core/providers/pdf_provider.dart';
import 'package:novel_v3/more_libs/setting/core/theme_listener.dart';
import 'package:novel_v3/core/providers/chapter_bookmark_provider.dart';
import 'package:novel_v3/core/providers/chapter_provider.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NovelProvider()),
        ChangeNotifierProvider(create: (context) => PdfProvider()),
        ChangeNotifierProvider(create: (context) => ChapterProvider()),
        ChangeNotifierProvider(create: (context) => ChapterBookmarkProvider()),
        ChangeNotifierProvider(create: (context) => NovelBookmarkProvider()),
      ],
      child: ThemeListener(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}
