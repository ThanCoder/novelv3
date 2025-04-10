import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:than_pkg/enums/screen_orientation_types.dart';

class PdfConfigModel {
  int page;
  bool isDarkMode;
  bool isPanLocked;
  bool isShowScrollThumb;
  double offsetDx;
  double offsetDy;
  double zoom;
  bool isKeepScreen;
  bool isTextSelection;
  double scrollByMouseWheel;
  String screenOrientation = ScreenOrientationTypes.Portrait.name;
  bool isOnBackpressConfirm;
  PdfConfigModel({
    this.page = 1,
    this.isDarkMode = false,
    this.isPanLocked = false,
    this.isShowScrollThumb = true,
    this.offsetDx = 0,
    this.offsetDy = 0,
    this.zoom = 0,
    this.isKeepScreen = false,
    this.isTextSelection = false,
    this.scrollByMouseWheel = 1.2,
    this.isOnBackpressConfirm = false,
  });

  factory PdfConfigModel.fromPath(String configPath) {
    final file = File(configPath);
    if (file.existsSync()) {
      try {
        final map = jsonDecode(file.readAsStringSync());
        return PdfConfigModel.fromMap(map);
      } catch (e) {
        file.deleteSync();
      }
      return PdfConfigModel();
    } else {
      //config မရှိ
      int pageIndex = 1;
      //check old config file
      final oldFile =
          File(configPath.replaceAll(pdfConfigName, pdfOldConfigName));
      if (oldFile.existsSync()) {
        try {
          final map = jsonDecode(oldFile.readAsStringSync());
          final index = map['pageIndex'] ?? 1;
          final indexDou = double.tryParse(index) ?? 1.0;
          pageIndex = indexDou.toInt();
        } catch (e) {
          debugPrint(e.toString());
        }
      }
      return PdfConfigModel(
        page: pageIndex,
        isDarkMode: false,
        isPanLocked: false,
        isShowScrollThumb: true,
      );
    }
  }

  factory PdfConfigModel.fromMap(Map<String, dynamic> map) {
    final config = PdfConfigModel(
      page: map['page'] ?? 1,
      offsetDx: map['offset_dx'] ?? 0,
      offsetDy: map['offset_dy'] ?? 0,
      zoom: map['zoom'] ?? 0,
      isDarkMode: map['dark_mode'] ?? false,
      isPanLocked: map['pan_locked'] ?? false,
      isShowScrollThumb: map['show_scroll_thumb'] ?? true,
      isKeepScreen: map['is_keep_screen'] ?? false,
      isTextSelection: map['is_text_selection'] ?? false,
      scrollByMouseWheel: map['scroll_by_mouse_wheel'] ?? 1.2,
      isOnBackpressConfirm: map['is_on_back_press_confirm'] ?? false,
    );
    config.screenOrientation =
        map['screen_orientation'] ?? ScreenOrientationTypes.Portrait.name;
    return config;
  }
  Future<void> saveConfig(String path) async {
    final file = File(path);
    await file
        .writeAsString(const JsonEncoder.withIndent(' ').convert(toJson()));
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'dark_mode': isDarkMode,
        'pan_locked': isPanLocked,
        'show_scroll_thumb': isShowScrollThumb,
        'offset_dx': offsetDx,
        'offset_dy': offsetDy,
        'zoom': zoom,
        'is_keep_screen': isKeepScreen,
        'is_text_selection': isTextSelection,
        'scroll_by_mouse_wheel': scrollByMouseWheel,
        'is_on_back_press_confirm': isOnBackpressConfirm,
        'screen_orientation': screenOrientation,
      };

  @override
  String toString() {
    return '\npage => $page\ndark_mode => $isDarkMode\npan_locked => $isPanLocked\nshow_scroll_thumb => $isShowScrollThumb\n';
  }
}
