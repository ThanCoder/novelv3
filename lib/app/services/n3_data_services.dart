import 'dart:io';
import 'dart:isolate';

import 'package:novel_v3/app/n3_data/n3_data.dart';
import 'package:than_pkg/than_pkg.dart';

class N3DataServices {
  static Future<List<N3Data>> getScanList() async {
    final pathList = await getScanPathList();
    final filterList = getFilterList();

    return await Isolate.run<List<N3Data>>(() async {
      List<N3Data> list = [];

      void scanDir(Directory dir) {
        for (var file in dir.listSync()) {
          // dir အနေမှာ စစ်မယ်
          //. စရင် ကျော်မယ်
          if (file.getName().startsWith('.')) continue;
          // list ထဲက ဟာတွေကျော်မယ်
          if (filterList.contains(file.getName())) continue;

          if (file.isFile) {
            // pdf စစ်မယ်
            if (N3Data.isN3Data(file.path)) {
              list.add(N3Data.createPath(file.path));
            }
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
