import 'dart:io';

import 'package:novel_v3/app/core/extensions/novel_extension.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/models/novel_meta.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:than_pkg/extensions/file_system_entity_extension.dart';
import 'package:uuid/uuid.dart';

class NovelServices {
  static Future<List<Novel>> getAll() async {
    List<Novel> list = [];
    final dir = Directory(PathUtil.getSourcePath());
    if (!dir.existsSync()) return list;
    for (var file in dir.listSync(followLinks: false)) {
      if (!file.isDirectory) continue;
      final novel = await Novel.fromPath(file.path);
      if (novel == null) continue;
      list.add(novel);
    }
    // sort
    list.sortDate();

    return list;
  }

  static Future<Novel> createNovelFolder({required NovelMeta meta}) async {
    final name = Uuid().v4();
    final dir = Directory(PathUtil.getSourcePath(name: name));
    if (!dir.existsSync()) {
      await dir.create();
    }
    final newMeta = meta.copyWith(id: name);
    await newMeta.save(dir.path);

    return Novel.create(name: name, path: dir.path, meta: newMeta);
  }
}
