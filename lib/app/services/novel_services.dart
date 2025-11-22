import 'dart:io';

import 'package:novel_v3/app/core/extensions/novel_extension.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelServices {
  static Future<List<Novel>> getList() async {
    final dir = Directory(PathUtil.getSourcePath());
    List<Novel> list = [];
    for (var file in dir.listSync(followLinks: false)) {
      if (!file.isDirectory) continue;
      final novel = await Novel.fromPath(file.path);
      list.add(novel);
    }
    // sort
    list.sortDate();
    return list;
  }
}
