import 'dart:io';

import 'package:than_pkg/than_pkg.dart';

import 'package:novel_v3/app/core/models/novel_meta.dart';

class Novel {
  final String title;
  final String path;
  final NovelMeta meta;
  final DateTime date;
  Novel({
    required this.title,
    required this.path,
    required this.meta,
    required this.date,
  });

  String get getCoverPath => '$path/cover.png';

  DateTime get getDate => Directory(path).getDate;

  int getSize() {
    int size = 0;
    final dir = Directory(path);
    if (!dir.existsSync()) return size;
    for (var file in dir.listSync(followLinks: false)) {
      if (!file.isFile) continue;
      size += file.getSize;
    }
    return size;
  }

  static Future<Novel?> fromPath(String path) async {
    final meta = await NovelMeta.fromPath(path);
    final dir = Directory(path);
    if (!dir.existsSync()) return null;
    return Novel(
      title: path.getName(),
      path: path,
      meta: meta,
      date: dir.getDate,
    );
  }

  Novel copyWith({
    String? title,
    String? path,
    NovelMeta? meta,
    DateTime? date,
  }) {
    return Novel(
      title: title ?? this.title,
      path: path ?? this.path,
      meta: meta ?? this.meta,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'path': path,
      'meta': meta.toMap(),
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Novel.fromMap(Map<String, dynamic> map) {
    return Novel(
      title: map['title'] as String,
      path: map['path'] as String,
      meta: NovelMeta.fromMap(map['meta'] as Map<String, dynamic>),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }
}
