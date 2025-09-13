// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:than_pkg/enums/screen_orientation_types.dart';
import 'package:than_pkg/than_pkg.dart';

import 'package:novel_v3/more_libs/pdf_readers_v1.1.2/pdf_reader.dart';

class PdfConfig {
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
  ScreenOrientationTypes screenOrientation;
  double scrollByArrowKey;
  bool isOnBackpressConfirm;
  bool isFullscreen;

  PdfConfig({
    required this.page,
    required this.isDarkMode,
    required this.isPanLocked,
    required this.isShowScrollThumb,
    required this.offsetDx,
    required this.offsetDy,
    required this.zoom,
    required this.isKeepScreen,
    required this.isTextSelection,
    required this.scrollByMouseWheel,
    required this.screenOrientation,
    required this.scrollByArrowKey,
    required this.isOnBackpressConfirm,
    required this.isFullscreen,
  });

  PdfConfig copyWith({
    int? page,
    bool? isDarkMode,
    bool? isPanLocked,
    bool? isShowScrollThumb,
    double? offsetDx,
    double? offsetDy,
    double? zoom,
    bool? isKeepScreen,
    bool? isTextSelection,
    double? scrollByMouseWheel,
    ScreenOrientationTypes? screenOrientation,
    double? scrollByArrowKey,
    bool? isOnBackpressConfirm,
    bool? isFullscreen,
  }) {
    return PdfConfig(
      page: page ?? this.page,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isPanLocked: isPanLocked ?? this.isPanLocked,
      isShowScrollThumb: isShowScrollThumb ?? this.isShowScrollThumb,
      offsetDx: offsetDx ?? this.offsetDx,
      offsetDy: offsetDy ?? this.offsetDy,
      zoom: zoom ?? this.zoom,
      isKeepScreen: isKeepScreen ?? this.isKeepScreen,
      isTextSelection: isTextSelection ?? this.isTextSelection,
      scrollByMouseWheel: scrollByMouseWheel ?? this.scrollByMouseWheel,
      screenOrientation: screenOrientation ?? this.screenOrientation,
      scrollByArrowKey: scrollByArrowKey ?? this.scrollByArrowKey,
      isOnBackpressConfirm: isOnBackpressConfirm ?? this.isOnBackpressConfirm,
      isFullscreen: isFullscreen ?? this.isFullscreen,
    );
  }

  factory PdfConfig.create({
    int page = 1,
    bool isDarkMode = false,
    bool isPanLocked = false,
    bool? isShowScrollThumb,
    double offsetDx = 0,
    double offsetDy = 0,
    double zoom = 0,
    bool isKeepScreen = false,
    bool isTextSelection = false,
    bool isFullscreen = false,
    bool isOnBackpressConfirm = false,
    double scrollByMouseWheel = 1.2,
    double scrollByArrowKey = 50,
    ScreenOrientationTypes screenOrientation = ScreenOrientationTypes.portrait,
  }) {
    return PdfConfig(
      page: page,
      isDarkMode: isDarkMode,
      isPanLocked: isPanLocked,
      isShowScrollThumb: isShowScrollThumb ?? TPlatform.isDesktop,
      offsetDx: offsetDx,
      offsetDy: offsetDy,
      zoom: zoom,
      isKeepScreen: isKeepScreen,
      isTextSelection: isTextSelection,
      scrollByMouseWheel: scrollByMouseWheel,
      screenOrientation: screenOrientation,
      scrollByArrowKey: scrollByArrowKey,
      isOnBackpressConfirm: isOnBackpressConfirm,
      isFullscreen: isFullscreen,
    );
  }

  factory PdfConfig.fromPath(String configPath) {
    final file = File(configPath);
    if (file.existsSync()) {
      final map = jsonDecode(file.readAsStringSync());
      return PdfConfig.fromMap(map);
    } else {
      return PdfConfig.create();
    }
  }

  void savePath(String configPath) {
    try {
      final file = File(configPath);
      final data = const JsonEncoder.withIndent(' ').convert(toMap());
      file.writeAsStringSync(data);
    } catch (e) {
      PdfReader.showDebugLog(e.toString(), tag: 'PdfConfig:savePath');
    }
  }

  factory PdfConfig.fromMap(Map<String, dynamic> map) {
    final screenOrientationStr = MapServices.getString(map, [
      'screenOrientation',
    ]);
    return PdfConfig(
      screenOrientation: ScreenOrientationTypes.getType(screenOrientationStr),

      page: MapServices.getInt(map, ['page'], defaultValue: 1),

      isDarkMode: MapServices.getBool(map, ['isDarkMode']),
      isPanLocked: MapServices.getBool(map, ['isPanLocked']),
      isShowScrollThumb: MapServices.getBool(map, ['isShowScrollThumb']),
      isFullscreen: MapServices.getBool(map, ['isFullscreen']),
      isKeepScreen: MapServices.getBool(map, ['isKeepScreen']),
      isTextSelection: MapServices.getBool(map, ['isTextSelection']),
      isOnBackpressConfirm: MapServices.getBool(map, ['isOnBackpressConfirm']),

      offsetDy: MapServices.getDouble(map, ['offsetDy']),
      offsetDx: MapServices.getDouble(map, ['offsetDx']),
      scrollByMouseWheel: MapServices.getDouble(map, [
        'scrollByMouseWheel',
      ], defaultValue: 1.2),
      zoom: MapServices.getDouble(map, ['zoom']),
      scrollByArrowKey: MapServices.getDouble(map, [
        'scrollByArrowKey',
      ], defaultValue: 50),
    );
  }

  // map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'page': page,
      'isDarkMode': isDarkMode,
      'isPanLocked': isPanLocked,
      'isShowScrollThumb': isShowScrollThumb,
      'offsetDx': offsetDx,
      'offsetDy': offsetDy,
      'zoom': zoom,
      'isKeepScreen': isKeepScreen,
      'isTextSelection': isTextSelection,
      'scrollByMouseWheel': scrollByMouseWheel,
      'screenOrientation': screenOrientation.name,
      'scrollByArrowKey': scrollByArrowKey,
      'isOnBackpressConfirm': isOnBackpressConfirm,
      'isFullscreen': isFullscreen,
    };
  }

  String toJson() => json.encode(toMap());

  factory PdfConfig.fromJson(String source) =>
      PdfConfig.fromMap(json.decode(source) as Map<String, dynamic>);
}
