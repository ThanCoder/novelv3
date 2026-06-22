import 'dart:io';
import 'dart:isolate';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/models/novel_meta.dart';
import 'package:path/path.dart';

class NovelSourceScanner {
  final String sourcePath;
  NovelSourceScanner(this.sourcePath);

  Novel? getNovelFromFolder(FileSystemEntity entry) {
    final meta = NovelMeta.fromPath(entry.path);
    if (meta == null) return null;
    return Novel(
      meta: meta,
      folderName: entry.getName(),
      size: getAllSizeDir(Directory(entry.path)),
    );
  }

  Future<List<Novel>> scan() async {
    return Isolate.run(() {
      final list = <Novel>[];
      final dir = Directory(sourcePath);
      if (!dir.existsSync()) return list;
      final dirList = dir.listSync();
      for (var file in dirList) {
        if (file.statSync().type != FileSystemEntityType.directory) continue;
        final novel = getNovelFromFolder(file);
        if (novel == null) continue;
        list.add(novel);
      }
      return list;
    });
  }
}

String getSourcePath([String? name1, String? name2, String? name3]) {
  final path = '/home/thancoder/Desktop/novel/.novel_v3/source';
  return join(path, name1, name2, name3);
}

Future<List<Novel>> getNovelsFromSource() async {
  return await NovelSourceScanner(getSourcePath()).scan();
}

int getAllSizeDir(Directory dir) {
  int size = 0;
  if (!dir.existsSync()) return size;
  for (var file in dir.listSync(followLinks: false, recursive: true)) {
    if (file.statSync().type != FileSystemEntityType.file) continue;
    size += file.statSync().size;
  }
  return size;
}
