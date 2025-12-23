import 'dart:io';

import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:than_pkg/than_pkg.dart';

import 'package:novel_v3/app/core/models/novel_meta.dart';
import 'package:uuid/uuid.dart';

class Novel {
  final String id;
  final String path;
  final NovelMeta meta;
  final DateTime date;
  int? size;
  Novel({
    required this.id,
    required this.path,
    required this.meta,
    required this.date,
    this.size,
  });
  factory Novel.create({
    required String name,
    String? path,
    NovelMeta? meta,
    String? id,
  }) {
    return Novel(
      id: id ?? Uuid().v4(),
      path: path ?? PathUtil.getSourcePath(name: name),
      meta: meta ?? NovelMeta.create(),
      date: DateTime.now(),
    );
  }

  Novel copyWith({String? id, String? path, NovelMeta? meta, DateTime? date}) {
    return Novel(
      id: id ?? this.id,
      path: path ?? this.path,
      meta: meta ?? this.meta,
      date: date ?? this.date,
    );
  }

  String get getCoverPath => '$path/cover.png';

  DateTime get getDate => Directory(path).getDate;

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

  int getSize() {
    if (size != null) return size ?? 0;
    int allSize = 0;
    final dir = Directory(path);
    if (!dir.existsSync()) return allSize;
    for (var file in dir.listSync(followLinks: false)) {
      if (!file.isFile) continue;
      allSize += file.getSize;
    }
    size = allSize;
    return allSize;
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
    return Novel(id: path.getName(), path: path, meta: meta, date: dir.getDate);
  }
}
