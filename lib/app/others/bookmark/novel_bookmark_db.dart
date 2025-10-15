import 'dart:io';

import 'package:novel_v3/app/core/interfaces/index.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_data.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/path_util.dart';

class NovelBookmarkDB extends JsonDatabase<NovelBookmarkData> {
  static NovelBookmarkDB? _instance;

  static NovelBookmarkDB getInstance() {
    _instance ??= NovelBookmarkDB();
    return _instance!;
  }

  NovelBookmarkDB()
    : super(root: '${PathUtil.getLibaryPath()}/novel_bookmark.db.json');

  Future<List<Novel>> getNovelList() async {
    // await Future.delayed(Duration(seconds: 3));
    final list = await getAll();

    return list
        .where(
          (e) =>
              Directory('${PathUtil.getSourcePath()}/${e.title}').existsSync(),
        )
        .map((e) => Novel.createTitle(e.title))
        .toList();
  }

  Future<void> toggleNovel(Novel novel) async {
    final list = await getAll();
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
  NovelBookmarkData from(Map<String, dynamic> map) {
    return NovelBookmarkData.fromMap(map);
  }

  @override
  String getId(NovelBookmarkData value) {
    return value.title;
  }

  @override
  Map<String, dynamic> to(NovelBookmarkData value) {
    return value.toMap();
  }
}
