import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';

extension DirectoryExtension on Directory {
  Future<int> getAllSize() async {
    int size = 0;
    for (var file in listSync(followLinks: false)) {
      if (file.isDirectory) continue;
      size += file.size;
    }
    return size;
  }
}
