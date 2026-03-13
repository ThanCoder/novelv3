import 'package:flutter/material.dart';
import 'package:novel_v3/other_apps/bookmark/novel_bookmark_provider.dart';
import 'package:novel_v3/old_app/ui/home/home_screen.dart';
import 'package:novel_v3/old_app/providers/novel_provider.dart';
import 'package:novel_v3/old_app/providers/pdf_provider.dart';
import 'package:novel_v3/more_libs/setting/core/theme_listener.dart';
import 'package:novel_v3/old_app/providers/chapter_bookmark_provider.dart';
import 'package:novel_v3/old_app/providers/chapter_provider.dart';
import 'package:provider/provider.dart';

class OldApp extends StatelessWidget {
  const OldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NovelProvider()),
        ChangeNotifierProvider(
          create: (context) => PdfProvider(context.read<NovelProvider>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ChapterProvider(context.read<NovelProvider>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ChapterBookmarkProvider(context.read<NovelProvider>()),
        ),
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
