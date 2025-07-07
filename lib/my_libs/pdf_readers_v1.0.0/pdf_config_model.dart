// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:than_pkg/enums/screen_orientation_types.dart';
import 'package:than_pkg/than_pkg.dart';

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
  double scrollByArrowKey;
  bool isOnBackpressConfirm;
  bool isFullscreen;
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
    this.scrollByArrowKey = 50,
    this.isFullscreen = false,
  });

  factory PdfConfigModel.create() {
    return PdfConfigModel(isShowScrollThumb: PlatformExtension.isDesktop());
  }

  factory PdfConfigModel.fromPath(String configPath) {
    final file = File(configPath);
    if (file.existsSync()) {
      final map = jsonDecode(file.readAsStringSync());
      return PdfConfigModel.fromMap(map);
    } else {
      return PdfConfigModel.create();
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
      scrollByArrowKey: map['scrollByArrowKey'] ?? 50.0,
      isFullscreen: map['isFullscreen'] ?? false,
    );
    config.screenOrientation =
        map['screen_orientation'] ?? ScreenOrientationTypes.Portrait.name;
    return config;
  }

  Map<String, dynamic> toMap() => {
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
        'scrollByArrowKey': scrollByArrowKey,
        'isFullscreen': isFullscreen,
      };

  void savePath(String configPath) {
    final file = File(configPath);
    final data = const JsonEncoder.withIndent(' ').convert(toMap());
    file.writeAsStringSync(data);
  }

  @override
  String toString() {
    return '\npage => $page\ndark_mode => $isDarkMode\npan_locked => $isPanLocked\nshow_scroll_thumb => $isShowScrollThumb\n';
  }
}
