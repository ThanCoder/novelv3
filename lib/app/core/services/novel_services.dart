import 'dart:io';

import 'package:novel_v3/app/core/extensions/novel_extension.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:than_pkg/extensions/file_system_entity_extension.dart';

class NovelServices {
  static final NovelServices instance = NovelServices._();
  NovelServices._();
  factory NovelServices() => instance;

  Future<List<Novel>> getAll() async {
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

  Future<Novel?> createNovelWithTitle(String title) async {
    final dir = Directory('${PathUtil.getSourcePath()}/$title');
    if (dir.existsSync()) return null;
    await dir.create();
    return Novel.fromPath(dir.path);
  }
}
