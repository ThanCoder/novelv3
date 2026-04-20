import 'dart:io';

import 'package:than_pkg/than_pkg.dart';

extension UtilStringExtensions on String {
  String formatUrl(String hostUrl) {
    return Utils.formatUrl(this, hostUrl);
  }
}

class Utils {
  static String formatUrl(String rawUrl, String hostUrl) {
    if (rawUrl.isEmpty) return rawUrl;
    String result = rawUrl;
    if (rawUrl.startsWith('/')) {
      result = '$hostUrl$rawUrl';
      result = result.replaceAll('//', '/');
      result = result.replaceAll(':/', '://');
    }
    if (rawUrl.startsWith('./')) {
      result = '$hostUrl${rawUrl.replaceAll('./', '/')}';
      result = result.replaceAll('//', '/');
      result = result.replaceAll(':/', '://');
    }
    if (rawUrl.startsWith('?')) {
      result = '$hostUrl$rawUrl';
    }
    return result;
  }
}

Future<List<String>> getScannerPath() async {
  List<String> list = [];
  final rootPath = await ThanPkg.platform.getAppExternalPath();
  if (rootPath == null) return list;
  if (Platform.isLinux) {
    list.add('$rootPath/Documents');
    list.add('$rootPath/Music');
    list.add('$rootPath/Pictures');
    list.add('$rootPath/Videos');
    list.add('$rootPath/Downloads');
  }
  if (Platform.isAndroid) {
    list.add('/storage/emulated/0');
  }
  return list;
}

List<String> getScannerFilterNames() {
  return ['Android', 'DCIM'];
}
