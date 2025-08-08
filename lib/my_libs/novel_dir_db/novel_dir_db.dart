import 'package:flutter/widgets.dart';
import 'package:novel_v3/my_libs/novel_dir_db/types/novel_pdf.dart';
import 'services/index.dart';
import 'types/chapter.dart';

export 'services/index.dart';
export 'types/index.dart';
export 'providers/index.dart';
export 'components/index.dart';
export 'views/index.dart';
export 'screens/index.dart';
export 'routs_helper.dart';
export 'extensions/index.dart';

class NovelDirDb {
  static final NovelDirDb instance = NovelDirDb._();
  NovelDirDb._();
  factory NovelDirDb() => instance;

  static bool isShowDebugLog = true;
  // await NovelDirDb.instance.init
  late String Function() getRootDirPath;
  late String Function() getAppCachePath;
  List<Widget> actionList = [];
  void Function(BuildContext context,NovelPdf pdf)? onPdfReader;
    void Function(BuildContext context,Chapter chapter)? onTextReader;

  Future<void> init({
    required String Function() getRootDirPath,
    required String Function() getAppCachePath,
    List<Widget> actionList = const [],
    bool isShowDebugLog = true,
    void Function(BuildContext context,NovelPdf pdf)? onPdfReader,
    void Function(BuildContext context,Chapter chapter)? onTextReader,
  }) async {
    this.getAppCachePath = getAppCachePath;
    this.getRootDirPath = getRootDirPath;
    this.actionList = actionList;
    NovelDirDb.isShowDebugLog = isShowDebugLog;
    this.onTextReader = onTextReader;
    this.onPdfReader = onPdfReader;
    // create dir
    await FolderFileServices.createDir(getRootDirPath());
    await FolderFileServices.createDir('${getRootDirPath()}/source');
    await FolderFileServices.createDir('${getRootDirPath()}/libary');
  }

  void goTextReader(BuildContext context,Chapter chapter) {
    if (onTextReader == null) {
      showDebugLog('text reader not setup!');
      return;
    }
    onTextReader!(context,chapter);
  }

  void goPdfReader(BuildContext context,NovelPdf pdf) {
    if (onPdfReader == null) {
      showDebugLog('pdf reader not setup!');
      return;
    }
    onPdfReader!(context,pdf);
  }

  // static
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
