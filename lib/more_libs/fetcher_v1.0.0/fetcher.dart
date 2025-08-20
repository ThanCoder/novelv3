import 'package:flutter/material.dart';

export 'screens/fetcher_chapter_screen.dart';
export 'fetch_send_data.dart';
export 'fetch_receive_data.dart';

typedef OnGetHtmlContent = Future<String> Function(String url);
typedef OnShowMessageCallback =
    void Function(BuildContext context, String message);

class Fetcher {
  // singleton
  static final Fetcher instance = Fetcher._();
  Fetcher._();
  factory Fetcher() => instance;

  // static
  static bool isShowDebugLog = true;

  late OnGetHtmlContent onGetHtmlContent;
  OnShowMessageCallback? _onShowMessage;
  OnShowMessageCallback? _onShowErrorMessage;

  // init
  Future<void> init({
    required OnGetHtmlContent onGetHtmlContent,
    bool isShowDebugLog = true,
    OnShowMessageCallback? onShowMessage,
    OnShowMessageCallback? onShowErrorMessage,
  }) async {
    Fetcher.isShowDebugLog = isShowDebugLog;
    this.onGetHtmlContent = onGetHtmlContent;
    _onShowMessage = onShowMessage;
    _onShowErrorMessage = onShowErrorMessage;
  }

  void showMessage(BuildContext context, String message) {
    _onShowMessage?.call(context, message);
  }

  void showErrorMessage(BuildContext context, String message) {
    _onShowErrorMessage?.call(context, message);
  }

  static void showDebugLog(String message, {String? tag}) {
    if (!isShowDebugLog) return;
    if (tag != null) {
      debugPrint('[$tag]: $message');
    } else {
      debugPrint(message);
    }
  }

  static String get getErrorLog {
    return ''' await Fetcher.instance.init''';
  }
}
