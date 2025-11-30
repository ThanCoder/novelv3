// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:than_pkg/services/t_map.dart';

import 'package:novel_v3/app/others/chapter_reader/reader_theme.dart';

class ChapterReaderConfig {
  final double fontSize;
  final double paddingX;
  final double paddingY;
  final bool isKeepScreening;
  final ReaderTheme theme;
  final bool isBackpressConfirm;
  const ChapterReaderConfig({
    required this.fontSize,
    required this.paddingX,
    required this.paddingY,
    required this.isKeepScreening,
    required this.theme,
    required this.isBackpressConfirm,
  });

  factory ChapterReaderConfig.create({
    double fontSize = 18,
    double paddingX = 2,
    double paddingY = 5,
    bool isKeepScreening = false,
    bool isBackpressConfirm = false,
    ReaderTheme? theme,
  }) {
    return ChapterReaderConfig(
      fontSize: fontSize,
      paddingX: paddingX,
      paddingY: paddingY,
      isKeepScreening: isKeepScreening,
      theme: Setting.getAppConfig.isDarkTheme
          ? ReaderTheme.defaultDarkTheme
          : ReaderTheme.defaultLightTheme,
      isBackpressConfirm: isBackpressConfirm,
    );
  }
  ChapterReaderConfig copyWith({
    double? fontSize,
    double? paddingX,
    double? paddingY,
    bool? isKeepScreening,
    ReaderTheme? theme,
    bool? isBackpressConfirm,
  }) {
    return ChapterReaderConfig(
      fontSize: fontSize ?? this.fontSize,
      paddingX: paddingX ?? this.paddingX,
      paddingY: paddingY ?? this.paddingY,
      isKeepScreening: isKeepScreening ?? this.isKeepScreening,
      theme: theme ?? this.theme,
      isBackpressConfirm: isBackpressConfirm ?? this.isBackpressConfirm,
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
      'isBackpressConfirm': isBackpressConfirm,
    };
  }

  factory ChapterReaderConfig.fromMap(Map<String, dynamic> map) {
    final themId = map.getString(['themeId'], def: '1');
    return ChapterReaderConfig(
      fontSize: map.getDouble(['fontSize'], def: 18),
      paddingX: map.getDouble(['paddingX'], def: 2),
      paddingY: map.getDouble(['paddingY'], def: 5),
      isKeepScreening: map.getBool(['isKeepScreening'], def: false),
      isBackpressConfirm: map.getBool(['isBackpressConfirm'], def: false),
      theme: ReaderTheme.getId(themId),
    );
  }
}
