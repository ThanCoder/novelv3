import 'package:flutter/widgets.dart';
import 'services/index.dart';

export 'services/index.dart';
export 'types/index.dart';
export 'providers/index.dart';
export 'components/index.dart';
export 'views/index.dart';

class NovelDirDb {
  static final NovelDirDb instance = NovelDirDb._();
  NovelDirDb._();
  factory NovelDirDb() => instance;

  static bool isShowDebugLog = true;
  // await NovelDirDb.instance.init
  late String Function() getRootDirPath;
  late String Function() getAppCachePath;
  List<Widget> actionList = [];

  Future<void> init({
    required String Function() getRootDirPath,
    required String Function() getAppCachePath,
    List<Widget> actionList = const [],
    bool isShowDebugLog = true,
  }) async {
    this.getAppCachePath = getAppCachePath;
    this.getRootDirPath = getRootDirPath;
    this.actionList = actionList;
    NovelDirDb.isShowDebugLog = isShowDebugLog;
    // create dir
    await FolderFileServices.createDir(getRootDirPath());
    await FolderFileServices.createDir('${getRootDirPath()}/source');
    await FolderFileServices.createDir('${getRootDirPath()}/libary');
  }

  static String get getInitErrorText {
    return 'await NovelDirDb.instance.init';
  }

  static void showDebugLog(String msg, {String? tag}) {
    if (!isShowDebugLog) return;
    if (tag != null) {
      debugPrint('[$tag]: $msg');
    }
    debugPrint(msg);
  }
}
