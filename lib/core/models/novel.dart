import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:novel_v3/core/models/novel_meta.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';

class Novel {
  final String id;
  final String path;
  final NovelMeta meta;
  final DateTime date;
  final int size;
  Novel({
    required this.id,
    required this.path,
    required this.meta,
    required this.date,
    this.size = 0,
  });
  factory Novel.create({required String id, String? path, NovelMeta? meta}) {
    return Novel(
      id: id,
      path: path ?? PathUtil.getSourcePath(name: id),
      meta: meta ?? NovelMeta.create(),
      date: DateTime.now(),
    );
  }

  String get getCoverPath => '$path/cover.png';

  DateTime get getDate => Directory(path).modified;

  List<String> get getConfigFiles {
    List<String> list = [];
    final dir = Directory(path);
    for (var file in dir.listSync(followLinks: false)) {
      if (!file.isFile) continue;
      if (!file.getName().endsWith('.json')) continue;
      list.add(file.getName());
    }
    return list;
  }

  List<String> get getPDFFiles {
    List<String> list = [];
    final dir = Directory(path);
    for (var file in dir.listSync(followLinks: false)) {
      if (!file.isFile) continue;
      if (!file.getName().endsWith('.pdf')) continue;
      list.add(file.getName());
    }
    return list;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'path': path,
      'meta': meta.toMap(),
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Novel.fromMap(Map<String, dynamic> map) {
    return Novel(
      id: map['id'] as String,
      path: map['path'] as String,
      meta: NovelMeta.fromMap(map['meta'] as Map<String, dynamic>),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }

  /// --- static ---
  static Future<Novel?> fromPath(String path) async {
    final meta = await NovelMeta.fromPath(path);
    final dir = Directory(path);
    if (!dir.existsSync()) return null;
    int size = 0;
    for (var file in dir.listSync(followLinks: false)) {
      if (!file.isFile) continue;
      size += await file.sizeAsync();
    }
    return Novel(
      id: path.getName(),
      path: path,
      meta: meta,
      date: dir.modified,
      size: size,
    );
  }

  Novel copyWith({
    String? id,
    String? path,
    NovelMeta? meta,
    DateTime? date,
    int? size,
  }) {
    return Novel(
      id: id ?? this.id,
      path: path ?? this.path,
      meta: meta ?? this.meta,
      date: date ?? this.date,
      size: size ?? this.size,
    );
  }
}
