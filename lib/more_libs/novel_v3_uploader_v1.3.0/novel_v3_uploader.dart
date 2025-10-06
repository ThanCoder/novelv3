import 'package:flutter/material.dart';
import 'ui/home_screen.dart';
import 'core/models/index.dart';

export 'core/index.dart';
export 'ui/index.dart';
export 'services/index.dart';

typedef OnDownloadUploaderFileCallback =
    void Function(BuildContext context, UploaderFile file);

class NovelV3Uploader {
  static final NovelV3Uploader instance = NovelV3Uploader._();
  NovelV3Uploader._();
  factory NovelV3Uploader() => instance;

  // static
  static String appLabelText = 'Static Server';
  static Widget get getHomeScreen => HomeScreen();

  // init props
  Future<String> Function(String url)? getContentFromUrl;
  // init class
  // await NovelV3Uploader.instance.init
  late String Function() getLocalServerPath;
  late String Function() getApiServerUrl;
  bool isShowDebugLog = true;
  String? imageCachePath;
  List<Widget> appBarActions = [];
  OnDownloadUploaderFileCallback? onDownloadUploaderFile;

  Future<void> init({
    required String Function() getLocalServerPath,
    required String Function() getApiServerUrl,
    Future<String> Function(String url)? getContentFromUrl,
    OnDownloadUploaderFileCallback? onDownloadUploaderFile,
    bool isShowDebugLog = true,
    String? imageCachePath,
    List<Widget> appBarActions = const [],
    String appLabelText = 'Static Server',
  }) async {
    this.getContentFromUrl = getContentFromUrl;
    this.isShowDebugLog = isShowDebugLog;
    this.getLocalServerPath = getLocalServerPath;
    this.getApiServerUrl = getApiServerUrl;
    this.imageCachePath = imageCachePath;
    this.appBarActions = appBarActions;
    this.onDownloadUploaderFile = onDownloadUploaderFile;
    NovelV3Uploader.appLabelText = appLabelText;
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
