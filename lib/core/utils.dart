import 'dart:io';
import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

extension NavigatorExtension on BuildContext {
  void closeNavigator({bool? isReturned}) {
    if (isReturned != null) {
      Navigator.pop(this, isReturned);
    } else {
      Navigator.pop(this);
    }
  }

  void goRoute({required Widget Function(BuildContext context) builder}) {
    Navigator.push(this, MaterialPageRoute(builder: builder));
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
