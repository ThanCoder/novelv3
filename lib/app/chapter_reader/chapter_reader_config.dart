import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/chapter_reader/reader_theme.dart';
import 'package:than_pkg/services/t_map.dart';

class ChapterReaderConfig {
  double fontSize;
  double paddingX;
  double paddingY;
  bool isKeepScreening;
  ReaderTheme theme;
  ChapterReaderConfig({
    required this.fontSize,
    required this.paddingX,
    required this.paddingY,
    required this.isKeepScreening,
    required this.theme,
  });

  factory ChapterReaderConfig.create({
    double fontSize = 18,
    double paddingX = 2,
    double paddingY = 5,
    bool isKeepScreening = false,
  }) {
    return ChapterReaderConfig(
      fontSize: fontSize,
      paddingX: paddingX,
      paddingY: paddingY,
      isKeepScreening: isKeepScreening,
      theme: ReaderTheme.defaultLightTheme,
    );
  }
  // path
  factory ChapterReaderConfig.fromPath(String path) {
    final file = File(path);
    if (file.existsSync()) {
      try {
        final json = jsonDecode(file.readAsStringSync());
        return ChapterReaderConfig.fromMap(json);
      } catch (e) {
        debugPrint('[ChapterReaderConfig.fromPath]: ${e.toString()}');
      }
    }
    return ChapterReaderConfig.create();
  }
  Future<void> savePath(String path) async {
    try {
      final file = File(path);
      final contents = JsonEncoder.withIndent(' ').convert(toMap());
      await file.writeAsString(contents);
    } catch (e) {
      debugPrint('[ChapterReaderConfig:savePath]: ${e.toString()}');
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fontSize': fontSize,
      'paddingX': paddingX,
      'paddingY': paddingY,
      'isKeepScreening': isKeepScreening,
      'themeId': theme.id,
    };
  }

  factory ChapterReaderConfig.fromMap(Map<String, dynamic> map) {
    final themId = map.getString(['themeId'], def: '1');
    return ChapterReaderConfig(
      fontSize: map.getDouble(['fontSize'], def: 18),
      paddingX: map.getDouble(['paddingX'], def: 2),
      paddingY: map.getDouble(['paddingY'], def: 5),
      isKeepScreening: map.getBool(['isKeepScreening'], def: false),
      theme: ReaderTheme.getId(themId),
    );
  }
}
