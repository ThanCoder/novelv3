import 'package:flutter/material.dart';

export 'components/android_screen_orientation_chooser.dart';
export 'components/pdf_bookmark_drawer.dart';
export 'dialogs/pdf_reader_setting_dialog.dart';
export 'types/pdf_bookmark.dart';
export 'types/pdf_config.dart';
export 'screens/custom_pdf_reader_screen.dart';
export 'screens/pdfrx_reader_screen.dart';

class PdfReader {
  static final PdfReader instance = PdfReader._();
  PdfReader._();
  factory PdfReader() => instance;
  // PdfReader.instance.init()
  late bool Function() getDarkTheme;
  void Function(BuildContext context, String msg)? showMessage;
  static bool isShowDebugLog = true;

  Future<void> init({
    bool Function()? getDarkTheme,
    void Function(BuildContext context, String msg)? showMessage,
    bool isShowDebugLog = true,
  }) async {
    this.getDarkTheme = getDarkTheme ?? () => false;
    this.showMessage = showMessage;
    PdfReader.isShowDebugLog = isShowDebugLog;
  }

  void showAutoMessage(BuildContext context, String msg) {
    if (showMessage == null) return;
    showMessage!(context, msg);
  }

  static void showDebugLog(String msg, {String? tag}) {
    if (isShowDebugLog) {
      if (tag != null) {
        debugPrint('[$tag]: $msg');
        return;
      }
      debugPrint(msg);
    }
  }
}
