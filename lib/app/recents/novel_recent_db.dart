import 'dart:io';

import 'package:novel_v3/app/novel_dir_app.dart';
import 'package:novel_v3/app/recents/novel_recent_data.dart';
import 'package:novel_v3/more_libs/json_database_v1.0.0/json_database.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/path_util.dart';

class NovelRecentDB extends JsonDBInterface<NovelRecentData> {
  static NovelRecentDB? _instance;

  static NovelRecentDB getInstance() {
    _instance ??= NovelRecentDB();
    return _instance!;
  }

  NovelRecentDB()
    : super(JsonIO.instance, '${PathUtil.getCachePath()}/novel_recent.db.json');

  @override
  NovelRecentData fromMap(Map<String, dynamic> map) {
    return NovelRecentData.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(NovelRecentData value) {
    return value.toMap();
  }

  Future<void> addRecent(Novel novel) async {
    final list = await get();
    final filteredList = list
        .where((e) => e.title != novel.title)
        .where(
          (e) =>
              Directory('${PathUtil.getSourcePath()}/${e.title}').existsSync(),
        )
        .toList();
    filteredList.insert(0, NovelRecentData(title: novel.title));

    await save(filteredList);
  }

  Future<List<Novel>> getNovelList() async {
    final list = await get();
    return list
        .where(
          (e) =>
              Directory('${PathUtil.getSourcePath()}/${e.title}').existsSync(),
        )
        .map((e) => Novel.createTitle(e.title))
        .toList();
  }
}
