import 'dart:io';
import 'dart:isolate';

import 'package:novel_v3/app/core/utils.dart';
import 'package:than_pkg/than_pkg.dart';

abstract class FileScannerInterface<T> {
  Future<T?> onParseFile(FileSystemEntity file);
  void onSort(List<T> list) {}

  Future<List<T>> scan() async {
    final scanList = await getScannerPath();
    final filterList = getScannerFilterNames();

    final res = await Isolate.run<List<T>>(() async {
      List<T> list = [];
      Future<void> scanDir(Directory dir) async {
        for (var file in dir.listSync(followLinks: false)) {
          final name = file.path.split('/').last;
          // dir အနေမှာ စစ်မယ်
          //. စရင် ကျော်မယ်
          if (name.startsWith('.')) continue;
          // list ထဲက ဟာတွေကျော်မယ်
          if (filterList.contains(name)) continue;

          if (file.isFile) {
            final res = await onParseFile(file);
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
      for (var path in scanList) {
        final dir = Directory(path);
        if (!dir.isDirectory) continue;
        await scanDir(dir);
      }
      return list;
    });
    onSort(res);

    return res;
  }
}
