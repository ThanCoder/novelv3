import 'dart:convert';
import 'dart:io';

import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/utils/path_util.dart';

class NovelRecentServices {
  static final NovelRecentServices instance = NovelRecentServices._();
  NovelRecentServices._();
  factory NovelRecentServices() => instance;

  Future<void> add(NovelModel novel) async {
    List<NovelModel> list = await getList();
    if (list.isEmpty) {
      list.insert(0, novel);
    } else {
      final isExists = list.first.title == novel.title;
      if (isExists) return;
      list.insert(0, novel);
    }

    final mapList = list.map((nv) => nv.toMap()).toList();
    final file = File(getPath());
    await file.writeAsString(jsonEncode(mapList));
  }

  Future<List<NovelModel>> getList() async {
    List<NovelModel> list = [];
    final file = File(getPath());
    if (await file.exists()) {
      List<dynamic> res = jsonDecode(await file.readAsString());
      list = res.map((map) => NovelModel.fromMap(map)).toList();
    }
    // await Future.delayed(const Duration(seconds: 2));
    return list;
  }

  String getPath() {
    return '${PathUtil.instance.getCachePath()}/recent.db.json';
  }
}
