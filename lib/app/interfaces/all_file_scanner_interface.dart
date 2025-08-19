import 'dart:io';
import 'dart:isolate';

import 'package:than_pkg/than_pkg.dart';

abstract class AllFileScannerInterface<T> {
  T? onParseFile(FileSystemEntity file);

  Future<List<T>> scanList() async {
    final pathList = await getScanPathList();
    final filterList = getFilterList();

    return await Isolate.run<List<T>>(() async {
      List<T> list = [];

      void scanDir(Directory dir) {
        for (var file in dir.listSync()) {
          final name = file.path.split('/').last;
          // dir အနေမှာ စစ်မယ်
          //. စရင် ကျော်မယ်
          if (name.startsWith('.')) continue;
          // list ထဲက ဟာတွေကျော်မယ်
          if (filterList.contains(name)) continue;

          if (file.isFile) {
            // // pdf စစ်မယ်
            // if (T.isPdf(file.path)) {
            //   list.add(T.createPath(file.path));
            // }
            final res = onParseFile(file);
            // null ဆိုရင် ကျော်မယ်
            if (res == null) continue;
            list.add(res);
          } else if (file.isDirectory) {
            // scan လုပ်မယ်
            scanDir(Directory(file.path));
          }
        }
      }

      // scan
      for (var path in pathList) {
        final dir = Directory(path);
        if (!dir.isDirectory) continue;
        scanDir(dir);
      }

      return list;
    });
  }

  static Future<List<String>> getScanPathList() async {
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
      list.add(rootPath);
    }
    return list;
  }

  static List<String> getFilterList() {
    return ['Android', 'DCIM'];
  }
}
