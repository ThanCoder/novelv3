import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/utils/path_util.dart';

class RecentServices {
  static Future<List<NovelModel>> getList() async {
    try {
      final file = File(getDBPath);
      if (!await file.exists()) return [];
      List<dynamic> resList = jsonDecode(await file.readAsString());
      return resList
          .where((name) =>
              Directory('${PathUtil.getSourcePath()}/$name')
                  .existsSync())
          .map((name) =>
              NovelModel.fromPath('${PathUtil.getSourcePath()}/$name'))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  static Future<void> setList({required List<NovelModel> list}) async {
    try {
      final file = File(getDBPath);
      final nameList = list.map((nv) => nv.title).toList();
      await file
          .writeAsString(const JsonEncoder.withIndent(' ').convert(nameList));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static String get getDBPath =>
      '${PathUtil.getCachePath()}/$novelRecentDBName';
}
