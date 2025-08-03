import 'package:flutter/material.dart';

export 'components/index.dart';
export 'models/index.dart';
export 'services/index.dart';
export 'extensions/index.dart';

class NovelV3Uploader {
  static final NovelV3Uploader instance = NovelV3Uploader._();
  NovelV3Uploader._();
  factory NovelV3Uploader() => instance;

  // init props
  Future<String> Function(String url)? onDownloadJson;
  // init class
  // await NovelV3Uploader.instance.init
  late String Function() getCustomServerPath;
  bool isShowDebugLog = true;
  String? imageCachePath;
  List<Widget> appBarActions = [];

  Future<void> init({
    String Function()? getCustomServerPath,
    bool isShowDebugLog = true,
    Future<String> Function(String url)? onDownloadJson,
    String? imageCachePath,
    List<Widget> appBarActions = const [],
  }) async {
    this.onDownloadJson = onDownloadJson;
    this.isShowDebugLog = isShowDebugLog;
    this.getCustomServerPath = getCustomServerPath ?? () => '';
    this.imageCachePath = imageCachePath;
    this.appBarActions = appBarActions;
  }

  void showLog(String msg) {
    if (NovelV3Uploader.instance.isShowDebugLog) {
      debugPrint(msg);
    }
  }

  String get getInitLog {
    return '''
await NovelV3Uploader.instance.init(
    NovelV3Uploader.instance.onDownloadJson: (url) async {
      return '';
    },
  );''';
  }
}
