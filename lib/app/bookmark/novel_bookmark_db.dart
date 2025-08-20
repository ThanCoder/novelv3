import 'dart:io';

import 'package:novel_v3/app/bookmark/novel_bookmark_data.dart';
import 'package:novel_v3/app/types/novel.dart';
import 'package:novel_v3/more_libs/json_database_v1.0.0/json_database.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/path_util.dart';

class NovelBookmarkDB extends JsonDBInterface<NovelBookmarkData> {
  static NovelBookmarkDB? _instance;

  static NovelBookmarkDB getInstance() {
    _instance ??= NovelBookmarkDB();
    return _instance!;
  }

  NovelBookmarkDB()
    : super(
        JsonIO.instance,
        '${PathUtil.getLibaryPath()}/novel_bookmark.db.json',
      );

  Future<List<Novel>> getNovelList() async {
    // await Future.delayed(Duration(seconds: 3));
    final list = await get();

    return list
        .where(
          (e) =>
              Directory('${PathUtil.getSourcePath()}/${e.title}').existsSync(),
        )
        .map((e) => Novel.createTitle(e.title))
        .toList();
  }

  Future<void> toggleNovel(Novel novel) async {
    final list = await get();
    final index = list.indexWhere((e) => e.title == novel.title);
    if (index == -1) {
      // မရှိ
      list.insert(0, NovelBookmarkData(title: novel.title));
    } else {
      //ရှိ
      list.removeAt(index);
    }
    await save(list);
  }

  @override
  NovelBookmarkData fromMap(Map<String, dynamic> map) {
    return NovelBookmarkData.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(NovelBookmarkData value) {
    return value.toMap();
  }
}
