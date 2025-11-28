import 'dart:io';

import 'package:flutter/widgets.dart';
/* 
  [Desktop Entry]
  Version=1.0
  Type=Application
  Name=Novel
  Comment=
  Exec=/home/than/Desktop/Novel/novel_v3
  Icon=/home/than/Desktop/Novel/data/flutter_assets/assets/cover.png
  Path=
  Terminal=false
  StartupNotify=false
  */

class DesktopExe {
  static Future<void> exportDesktopIcon({
    required String name,
    required String assetsIconPath,
    String? customDesktopFilePath,
    String? customExePath,
    String? customIconPath,
    String path = '',
    bool terminal = false,
    bool startupNotify = false,
  }) async {
    try {
      if (!Platform.isLinux) return;
      final desktopFilePath =
          customDesktopFilePath ??
          '${Platform.environment['HOME']}/Desktop/${name.replaceAll(' ', '_')}.desktop';
      //
      final assetsRealIconPath =
          '${File(Platform.resolvedExecutable).parent.path}/data/flutter_assets/$assetsIconPath';

      // write content
      final file = File(desktopFilePath);
      // file ရှိနေရင် မထုတ်တော့ဘူး
      if (file.existsSync()) return;

      final stringBuff = StringBuffer();
      stringBuff.writeln('[Desktop Entry]');
      stringBuff.writeln('Version=1.0');
      stringBuff.writeln('Type=Application');
      stringBuff.writeln('Name=$name');
      stringBuff.writeln('Comment=');
      stringBuff.writeln(
        'Exec=${customExePath ?? Platform.resolvedExecutable}',
      );
      stringBuff.writeln('Icon=${customIconPath ?? assetsRealIconPath}');
      stringBuff.writeln(
        'Path=${File(customExePath ?? Platform.resolvedExecutable).parent.path}',
      );
      stringBuff.writeln('Terminal=$terminal');
      stringBuff.writeln('StartupNotify=$startupNotify');

      await file.writeAsString(stringBuff.toString());
    } catch (e) {
      debugPrint('[DesktopExe:exportDesktopIcon]: ${e.toString()}');
    }
  }
}
