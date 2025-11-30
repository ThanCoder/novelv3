import 'package:flutter/material.dart';
import 'package:novel_v3/app/ui/home/home_screen.dart';
import 'package:novel_v3/more_libs/setting/core/theme_listener.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeListener(
      builder: (context, themeMode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: HomeScreen(),
        );
      },
    );
  }
}
