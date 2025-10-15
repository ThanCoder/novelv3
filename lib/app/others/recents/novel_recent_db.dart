import 'dart:io';

import 'package:novel_v3/app/core/interfaces/index.dart';
import 'package:novel_v3/app/ui/novel_dir_app.dart';
import 'package:novel_v3/app/others/recents/novel_recent_data.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/path_util.dart';

class NovelRecentDB extends JsonDatabase<NovelRecentData> {
  static NovelRecentDB? _instance;

  static NovelRecentDB getInstance() {
    _instance ??= NovelRecentDB();
    return _instance!;
  }

  NovelRecentDB()
    : super(root: '${PathUtil.getCachePath()}/novel_recent.db.json');

  Future<void> addRecent(Novel novel) async {
    final list = await getAll();
    final filteredList = list
        .where((e) => e.title != novel.title)
        .where(
          (e) =>
              Directory('${PathUtil.getSourcePath()}/${e.title}').existsSync(),
        )
        .toList();
    final value = NovelRecentData(title: novel.title);
    filteredList.insert(0, value);

    await save(filteredList);
    notify(DatabaseListenerEvent.add, id: getId(value));
  }

  Future<List<Novel>> getNovelList() async {
    final list = await getAll();
    return list
        .where(
          (e) =>
              Directory('${PathUtil.getSourcePath()}/${e.title}').existsSync(),
        )
        .map((e) => Novel.createTitle(e.title))
        .toList();
  }

  @override
  NovelRecentData from(Map<String, dynamic> map) {
    return NovelRecentData.fromMap(map);
  }

  @override
  String getId(NovelRecentData value) {
    return value.title;
  }

  @override
  Map<String, dynamic> to(NovelRecentData value) {
    return value.toMap();
  }
}
