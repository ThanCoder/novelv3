import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/models/novel_meta.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:than_pkg/extensions/file_system_entity_extension.dart';
import 'package:than_pkg/utils/f_path.dart';
import 'package:uuid/uuid.dart';

class NovelServices {
  NovelServices._();
  static final instance = NovelServices._();
  factory NovelServices() => instance;

  Future<String> getNovelFullPath(String id) async {
    final dir = Directory(PathUtil.getSourcePath(name: id));
    if (!dir.existsSync()) {
      await dir.create();
    }
    return dir.path;
  }

  Future<Novel?> getById(String id) async {
    final dir = Directory(PathUtil.getSourcePath(name: id));
    if (!dir.existsSync()) return null;
    return await Novel.fromPath(dir.path);
  }

  Future<List<Novel>> getAll() async {
    final path = PathUtil.getSourcePath();
    return await compute(_fetchNovelsInBackground, path);
  }

  Future<void> updateNovel(String id, Novel novel) async {
    final dir = Directory(PathUtil.getSourcePath(name: id));
    if (!dir.existsSync()) {
      await dir.create();
    }
    await novel.meta.save(dir.path);
  }

  Future<void> deleteNovel(String id) async {
    final dir = Directory(PathUtil.getSourcePath(name: id));
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  Future<Novel> createNovel({required NovelMeta meta, String? oldId}) async {
    final id = oldId ?? Uuid().v4();
    final dir = Directory(PathUtil.getSourcePath(name: id));
    if (!dir.existsSync()) {
      await dir.create();
    }
    final newMeta = meta.copyWith(id: id, date: DateTime.now());
    await newMeta.save(dir.path);

    return Novel.create(id: id, path: dir.path, meta: newMeta);
  }

  Future<NovelMeta?> getNovelMeta(String id) async {
    final dir = Directory(PathUtil.getSourcePath(name: id));
    if (!dir.existsSync()) return null;
    final file = File(pathJoin(dir.path, 'meta.json'));
    if (!file.existsSync()) return null;
    return await NovelMeta.fromPath(file.path);
  }

  Future<bool> existsNovel(String id) async {
    final dir = Directory(PathUtil.getSourcePath(name: id));
    return dir.existsSync();
  }

  Future<bool> existsNovelMetaFile(String id) async {
    final dir = Directory(PathUtil.getSourcePath(name: id));
    if (!dir.existsSync()) return dir.existsSync();
    final file = File(pathJoin(dir.path, 'meta.json'));
    return await file.exists();
  }

  Future<bool> existsNovelOtherFile(
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

// သီးခြားခွဲထုတ်ထားတဲ့ Top-level function
Future<List<Novel>> _fetchNovelsInBackground(String sourcePath) async {
  List<Novel> list = [];
  final dir = Directory(sourcePath);

  if (!dir.existsSync()) return list;

  // listSync ထက် list() (Stream) က ပိုကောင်းနိုင်ပေမယ့်
  // background မှာမို့ Sync သုံးလည်း UI ကို မထိခိုက်တော့ပါဘူး
  await for (var file in dir.list(followLinks: false)) {
    if (file is! Directory) continue;

    final novel = await Novel.fromPath(file.path);
    if (novel == null) continue;
    list.add(novel);
  }
  return list;
}
