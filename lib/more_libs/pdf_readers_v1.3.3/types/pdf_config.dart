// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:than_pkg/enums/screen_orientation_types.dart';
import 'package:than_pkg/than_pkg.dart';

import 'package:novel_v3/more_libs/pdf_readers_v1.3.3/pdf_reader.dart';

class PdfConfig {
  final int page;
  final bool isDarkMode;
  final bool isLockScreen;
  final bool isShowScrollThumb;
  final double offsetDx;
  final double zoom;
  final bool isKeepScreen;
  final bool isTextSelection;
  final double scrollByMouseWheel;
  final ScreenOrientationTypes screenOrientation;
  final double scrollByArrowKey;
  final bool isOnBackpressConfirm;
  final bool isFullscreen;
  final bool useProgressiveLoading;

  const PdfConfig({
    required this.page,
    required this.isDarkMode,
    required this.isLockScreen,
    required this.isShowScrollThumb,
    required this.offsetDx,
    required this.zoom,
    required this.isKeepScreen,
    required this.isTextSelection,
    required this.scrollByMouseWheel,
    required this.screenOrientation,
    required this.scrollByArrowKey,
    required this.isOnBackpressConfirm,
    required this.isFullscreen,
    required this.useProgressiveLoading,
  });

  PdfConfig copyWith({
    int? page,
    bool? isDarkMode,
    bool? isLockScreen,
    bool? isShowScrollThumb,
    double? offsetDx,
    double? zoom,
    bool? isKeepScreen,
    bool? isTextSelection,
    double? scrollByMouseWheel,
    ScreenOrientationTypes? screenOrientation,
    double? scrollByArrowKey,
    bool? isOnBackpressConfirm,
    bool? isFullscreen,
    bool? useProgressiveLoading,
  }) {
    return PdfConfig(
      page: page ?? this.page,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isLockScreen: isLockScreen ?? this.isLockScreen,
      isShowScrollThumb: isShowScrollThumb ?? this.isShowScrollThumb,
      offsetDx: offsetDx ?? this.offsetDx,
      zoom: zoom ?? this.zoom,
      isKeepScreen: isKeepScreen ?? this.isKeepScreen,
      isTextSelection: isTextSelection ?? this.isTextSelection,
      scrollByMouseWheel: scrollByMouseWheel ?? this.scrollByMouseWheel,
      screenOrientation: screenOrientation ?? this.screenOrientation,
      scrollByArrowKey: scrollByArrowKey ?? this.scrollByArrowKey,
      isOnBackpressConfirm: isOnBackpressConfirm ?? this.isOnBackpressConfirm,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      useProgressiveLoading:
          useProgressiveLoading ?? this.useProgressiveLoading,
    );
  }

  factory PdfConfig.create({
    int page = 1,
    bool isDarkMode = false,
    bool isLockScreen = true,
    bool? isShowScrollThumb,
    double offsetDx = 0,
    double zoom = 0,
    bool isKeepScreen = false,
    bool isTextSelection = false,
    bool isFullscreen = false,
    bool isOnBackpressConfirm = false,
    double scrollByMouseWheel = 1.2,
    double scrollByArrowKey = 50,
    ScreenOrientationTypes screenOrientation = ScreenOrientationTypes.portrait,
    bool useProgressiveLoading = true,
  }) {
    return PdfConfig(
      page: page,
      isDarkMode: isDarkMode,
      isLockScreen: isLockScreen,
      isShowScrollThumb: isShowScrollThumb ?? TPlatform.isDesktop,
      offsetDx: offsetDx,
      zoom: zoom,
      isKeepScreen: isKeepScreen,
      isTextSelection: isTextSelection,
      scrollByMouseWheel: scrollByMouseWheel,
      screenOrientation: screenOrientation,
      scrollByArrowKey: scrollByArrowKey,
      isOnBackpressConfirm: isOnBackpressConfirm,
      isFullscreen: isFullscreen,
      useProgressiveLoading: useProgressiveLoading,
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
    final screenOrientationStr = map.getString(['screenOrientation']);
    return PdfConfig(
      useProgressiveLoading: map.getBool(['useProgressiveLoading'], def: true),
      screenOrientation: ScreenOrientationTypes.getType(screenOrientationStr),
      page: map.getInt(['page'], def: 1),
      isDarkMode: map.getBool(['isDarkMode']),
      isLockScreen: map.getBool(['isLockScreen'], def: true),
      isShowScrollThumb: map.getBool([
        'isShowScrollThumb',
      ], def: TPlatform.isDesktop),
      isFullscreen: map.getBool(['isFullscreen']),
      isKeepScreen: map.getBool(['isKeepScreen']),
      isTextSelection: map.getBool(['isTextSelection']),
      isOnBackpressConfirm: map.getBool(['isOnBackpressConfirm']),
      offsetDx: map.getDouble(['offsetDx']),
      scrollByMouseWheel: map.getDouble(['scrollByMouseWheel'], def: 1.2),
      zoom: map.getDouble(['zoom']),
      scrollByArrowKey: map.getDouble(['scrollByArrowKey'], def: 50),
    );
  }

  // map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'page': page,
      'isDarkMode': isDarkMode,
      'isLockScreen': isLockScreen,
      'isShowScrollThumb': isShowScrollThumb,
      'offsetDx': offsetDx,
      'zoom': zoom,
      'isKeepScreen': isKeepScreen,
      'isTextSelection': isTextSelection,
      'scrollByMouseWheel': scrollByMouseWheel,
      'screenOrientation': screenOrientation.name,
      'scrollByArrowKey': scrollByArrowKey,
      'isOnBackpressConfirm': isOnBackpressConfirm,
      'isFullscreen': isFullscreen,
      'useProgressiveLoading': useProgressiveLoading,
    };
  }

  String toJson() => json.encode(toMap());

  factory PdfConfig.fromJson(String source) =>
      PdfConfig.fromMap(json.decode(source) as Map<String, dynamic>);
}
