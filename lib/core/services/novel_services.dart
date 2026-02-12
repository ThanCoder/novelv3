import 'dart:io';

import 'package:novel_v3/core/extensions/novel_extension.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/models/novel_meta.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:than_pkg/extensions/file_system_entity_extension.dart';
import 'package:than_pkg/utils/f_path.dart';
import 'package:uuid/uuid.dart';

class NovelServices {
  static Future<String> getNovelFullPath(String id) async {
    final dir = Directory(PathUtil.getSourcePath(name: id));
    if (!dir.existsSync()) {
      await dir.create();
    }
    return dir.path;
  }

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

  static Future<Novel> createNovelFolder({
    required NovelMeta meta,
    String? oldId,
  }) async {
    final name = oldId ?? Uuid().v4();
    final dir = Directory(PathUtil.getSourcePath(name: name));
    if (!dir.existsSync()) {
      await dir.create();
    }
    final newMeta = meta.copyWith(id: name, date: DateTime.now());
    await newMeta.save(dir.path);

    return Novel.create(name: name, path: dir.path, meta: newMeta);
  }

  static Future<NovelMeta?> getNovelMeta(String id) async {
    final dir = Directory(PathUtil.getSourcePath(name: id));
    if (!dir.existsSync()) return null;
    final file = File(pathJoin(dir.path, 'meta.json'));
    if (!file.existsSync()) return null;
    return await NovelMeta.fromPath(file.path);
  }

  static Future<bool> existsNovel(String id) async {
    final dir = Directory(PathUtil.getSourcePath(name: id));
    return dir.existsSync();
  }

  static Future<bool> existsNovelMetaFile(String id) async {
    final dir = Directory(PathUtil.getSourcePath(name: id));
    if (!dir.existsSync()) return dir.existsSync();
    final file = File(pathJoin(dir.path, 'meta.json'));
    return await file.exists();
  }

  static Future<bool> existsNovelOtherFile(
    String id,
    String filename, {
    int? checkSize,
  }) async {
    final dir = Directory(PathUtil.getSourcePath(name: id));
    if (!dir.existsSync()) return dir.existsSync();
    final file = File(pathJoin(dir.path, filename));
    if (checkSize != null && file.existsSync()) {
      return file.getSize == checkSize;
    }
    return await file.exists();
  }
}
