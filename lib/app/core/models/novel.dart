import 'dart:io';

import 'package:novel_v3/app/core/models/novel_meta.dart';
import 'package:than_pkg/than_pkg.dart';

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
}
