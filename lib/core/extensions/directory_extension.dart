import 'dart:io';

import 'package:than_pkg/than_pkg.dart';

extension DirectoryExtension on Directory {
  Future<int> getAllSize() async {
    int size = 0;
    for (var file in listSync(followLinks: false)) {
      if (file.isDirectory) continue;
      size += file.getSize;
    }
    return size;
  }
}
