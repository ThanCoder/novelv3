import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/chapter_reader/reader_theme.dart';
import 'package:t_widgets/t_widgets.dart';

class ChapterReaderThemeListener extends StatefulWidget {
  final ReaderTheme theme;
  final Widget Function(BuildContext context, ThemeData themeData) builder;
  const ChapterReaderThemeListener({
    super.key,
    required this.theme,
    required this.builder,
  });

  @override
  State<ChapterReaderThemeListener> createState() =>
      _ChapterReaderThemeListenerState();
}

class _ChapterReaderThemeListenerState
    extends State<ChapterReaderThemeListener> {
  @override
  void initState() {
    _brightnessSub = PBrightnessServices().onBrightnessChanged.listen((data) {
      if (widget.theme.id == ReaderTheme.systemTheme.id) {
        currentBrighness = data;
        init();
      }
    });
    currentTheme = ThemeData.light();
    super.initState();
    init();
  }

  @override
  void dispose() {
    _brightnessSub.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChapterReaderThemeListener oldWidget) {
    if (oldWidget.theme.id != widget.theme.id) {
      init();
    }
    super.didUpdateWidget(oldWidget);
  }

  late ThemeData currentTheme;
  late StreamSubscription<Brightness> _brightnessSub;
  Brightness currentBrighness = PBrightnessServices().currentBrightness;

  void init() async {
    if (widget.theme.id == ReaderTheme.systemTheme.id) {
      currentTheme = currentBrighness.isDark
          ? ThemeData.dark()
          : ThemeData.light();
      setState(() {});
      return;
    }
    if (widget.theme.id == ReaderTheme.defaultDarkTheme.id) {
      currentTheme = ThemeData.dark();
      setState(() {});
      return;
    }
    if (widget.theme.id == ReaderTheme.defaultLightTheme.id) {
      currentTheme = ThemeData.light();
      setState(() {});
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, currentTheme);
  }
}
