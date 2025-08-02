import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppServices {
  static Future<void> clearAndRefreshImage() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static void copyText(String text) {
    try {
      Clipboard.setData(ClipboardData(text: text));
    } catch (e) {
      debugPrint('copyText: ${e.toString()}');
    }
  }

  static Future<String> pasteFromClipboard() async {
    String res = '';
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null) {
      res = data.text ?? '';
    }
    return res;
  }

  
}
