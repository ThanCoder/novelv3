import 'dart:io';

extension PlatformExtension on Platform {
  static bool isDesktop() {
    return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
  }

  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }
}
