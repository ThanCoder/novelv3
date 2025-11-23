import 'dart:io';

import 'package:than_pkg/than_pkg.dart';

import 'package:novel_v3/app/core/models/novel_meta.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';

class Novel {
  final String title;
  final String path;
  final DateTime date;
  NovelMeta meta;
  int cacheSize = 0;
  bool cacheIsOnlineExists = false;

  Novel({
    required this.title,
    required this.path,
    required this.meta,
    required this.date,
  });

  static Future<Novel> createTitle(String title) async {
    final dir = Directory('${PathUtil.getSourcePath()}/$title');
    dir.createSync(recursive: true);
    return await Novel.fromPath(dir.path);
  }

  static Future<Novel> fromPath(String path) async {
    final dir = Directory(path);
    return Novel(
      title: path.getName(),
      path: path,
      date: dir.statSync().modified,
      meta: await NovelMeta.fromPath(path),
    );
  }

  Future<void> setMeta(NovelMeta newMeta) async {
    meta = newMeta;
    await meta.save(path);
  }

  Future<void> deleteForever() async {
    await PathUtil.deleteDir(Directory(path));
  }

  bool isExistsNovelData() {
    return false;
  }

  bool get isExistsDesc => meta.desc.isNotEmpty;

  bool get isN3DataExported => false;

  int get getSizeInt {
    return cacheSize;
  }

  String get getCoverPath => '$path/cover.png';
  String get getChapterBookmarkPath => '$path/fav_list2.json';

  Future<String> getAllSizeLabel() async {
    if (cacheSize > 0) {
      return cacheSize.toDouble().toFileSizeLabel();
    }
    final size = await getAllSize();
    return size.toDouble().toFileSizeLabel();
  }

  Future<int> getAllSize() async {
    if (cacheSize > 0) return cacheSize;

    final dir = Directory(path);
    if (!dir.existsSync()) return 0;
    int size = 0;
    for (var file in dir.listSync(followLinks: false)) {
      if (file is File) {
        size += await file.length();
      }
    }
    cacheSize = size;
    return size;
  }

  @override
  String toString() => 'title: $title';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'path': path,
      'date': date.millisecondsSinceEpoch,
      'meta': meta.toMap(),
    };
  }

  factory Novel.fromMap(Map<String, dynamic> map) {
    return Novel(
      title: map['title'] as String,
      path: map['path'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      meta: NovelMeta.fromMap(map['meta'] as Map<String, dynamic>),
    );
  }

  Novel copyWith({
    String? title,
    String? path,
    DateTime? date,
    NovelMeta? meta,
  }) {
    return Novel(
      title: title ?? this.title,
      path: path ?? this.path,
      date: date ?? this.date,
      meta: meta ?? this.meta,
    );
  }
}
