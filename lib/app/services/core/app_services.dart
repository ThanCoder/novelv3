import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:than_pkg/than_pkg.dart';

Future<void> clearAndRefreshImage() async {
  PaintingBinding.instance.imageCache.clear();
  PaintingBinding.instance.imageCache.clearLiveImages();
  await Future.delayed(const Duration(milliseconds: 500));
}

void copyText(String text) {
  try {
    Clipboard.setData(ClipboardData(text: text));
  } catch (e) {
    debugPrint('copyText: ${e.toString()}');
  }
}

Future<String> pasteFromClipboard() async {
  String res = '';
  ClipboardData? data = await Clipboard.getData('text/plain');
  if (data != null) {
    res = data.text ?? '';
  }
  return res;
}

//toggleFullScreen
void toggleFullScreenPlatform(bool isFullScreen) async {
  await ThanPkg.platform.toggleFullScreen(isFullScreen: isFullScreen);
}

//keep screen
void toggleAndroidKeepScreen(bool isKeep) async {
  if (!Platform.isAndroid) return;
  await ThanPkg.android.app.toggleKeepScreenOn(isKeep: isKeep);
}
