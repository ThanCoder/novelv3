import 'package:flutter/widgets.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:novel_v3/app/screens/chapter_reader/chapter_reader_screen.dart';
import 'package:novel_v3/app/types/novel_pdf.dart';
import 'package:novel_v3/more_libs/pdf_readers_v1.0.1/pdf_reader.dart';
import 'services/index.dart';
import 'types/chapter.dart';

export 'services/index.dart';
export 'types/index.dart';
export 'providers/index.dart';
export 'components/index.dart';
export 'views/index.dart';
export 'screens/index.dart';
export 'extensions/index.dart';

class NovelDirApp {
  static final NovelDirApp instance = NovelDirApp._();
  NovelDirApp._();
  factory NovelDirApp() => instance;

  static bool isShowDebugLog = true;
  // await NovelDirApp.instance.init
  late String Function() getRootDirPath;
  late String Function() getAppCachePath;
  List<Widget> actionList = [];
  void Function(BuildContext context, String message)? _onShowMessage;

  Future<void> init({
    required String Function() getRootDirPath,
    required String Function() getAppCachePath,
    void Function(BuildContext context, String message)? onShowMessage,
    List<Widget> actionList = const [],
    bool isShowDebugLog = true,
  }) async {
    this.getAppCachePath = getAppCachePath;
    this.getRootDirPath = getRootDirPath;
    this.actionList = actionList;
    NovelDirApp.isShowDebugLog = isShowDebugLog;
    _onShowMessage = onShowMessage;
    // create dir
    await FolderFileServices.createDir(getRootDirPath());
    await FolderFileServices.createDir('${getRootDirPath()}/source');
    await FolderFileServices.createDir('${getRootDirPath()}/libary');
  }

  void goTextReader(BuildContext context, Chapter chapter) {
    goRoute(
      context,
      builder: (context) => ChapterReaderScreen(chapter: chapter),
    );
  }

  void goPdfReader(BuildContext context, NovelPdf pdf) {
    goRoute(
      context,
      builder: (context) => PdfrxReaderScreen(
        sourcePath: pdf.path,
        pdfConfig: PdfConfigModel.fromPath(pdf.getConfigPath),
        title: pdf.getTitle,
        onConfigUpdated: (pdfConfig) {
          pdfConfig.savePath(pdf.getConfigPath);
        },
      ),
    );
  }

  void showMessage(BuildContext context, String message) {
    if (_onShowMessage == null) return;
    _onShowMessage!(context, message);
  }

  // static
  static String get getInitErrorText {
    return 'await NovelDirApp.instance.init';
  }

  static void showDebugLog(String msg, {String? tag}) {
    if (!isShowDebugLog) return;
    if (tag != null) {
      debugPrint('[$tag]: $msg');
    }
    debugPrint(msg);
  }
}
