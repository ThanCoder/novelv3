// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:than_pkg/than_pkg.dart' hide TPlatform;

import 'package:novel_v3/other_apps/pdf_reader/pdf_reader.dart';
import 'package:novel_v3/other_apps/pdf_reader/types/pdf_reader_type.dart';

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
  final PdfReaderType readerType;
  final double readerOffsetX;

  const PdfConfig({
    required this.readerOffsetX,
    required this.page,
    required this.readerType,
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

  factory PdfConfig.create({
    int page = 1,
    bool isDarkMode = false,
    bool isLockScreen = true,
    bool? isShowScrollThumb,
    double offsetDx = 0,
    double zoom = 1.0,
    bool isKeepScreen = false,
    bool isTextSelection = false,
    bool isFullscreen = false,
    bool isOnBackpressConfirm = false,
    double scrollByMouseWheel = 1.2,
    double scrollByArrowKey = 50,
    ScreenOrientationTypes screenOrientation = ScreenOrientationTypes.portrait,
    bool useProgressiveLoading = false,
    PdfReaderType readerType = PdfReaderType.RXPdfReader,
  }) {
    return PdfConfig(
      page: page,
      readerType: readerType,
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
      readerOffsetX: 0.0,
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
      readerOffsetX: map.getDouble(['readerOffsetX'], def: 0.0),
      readerType: PdfReaderType.getType(map.getString(['pdf_reader_type'])),
      useProgressiveLoading: map.getBool(['useProgressiveLoading'], def: false),
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
      zoom: map.getDouble(['zoom'], def: 1.0),
      scrollByArrowKey: map.getDouble(['scrollByArrowKey'], def: 50),
    );
  }

  // map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'readerOffsetX': readerOffsetX,
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
      'pdf_reader_type': readerType.name,
    };
  }

  String toJson() => json.encode(toMap());

  factory PdfConfig.fromJson(String source) =>
      PdfConfig.fromMap(json.decode(source) as Map<String, dynamic>);

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
    PdfReaderType? readerType,
    double? readerOffsetX,
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
      readerType: readerType ?? this.readerType,
      readerOffsetX: readerOffsetX ?? this.readerOffsetX,
    );
  }
}
