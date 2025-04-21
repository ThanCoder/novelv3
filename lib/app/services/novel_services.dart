import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/utils/path_util.dart';

class NovelServices {
  static final NovelServices instance = NovelServices._();
  NovelServices._();
  factory NovelServices() => instance;

  Future<List<NovelModel>> getList({bool isFullInfo = false}) async {
    final path = PathUtil.instance.getSourcePath();
    List<NovelModel> list = await Isolate.run<List<NovelModel>>(() async {
      try {
        List<NovelModel> list = [];
        final dir = Directory(path);
        //skiped not dir
        if (!await dir.exists()) return [];
        for (var file in dir.listSync()) {
          //skiped not dir
          if (file.statSync().type != FileSystemEntityType.directory) continue;
          final novel = NovelModel.fromPath(file.path, isFullInfo: isFullInfo);
          list.add(novel);
        }
        //sort
        list.sort((a, b) {
          if (a.date > b.date) return -1;
          if (a.date < b.date) return 1;
          return 0;
        });
        return list;
      } catch (e) {
        debugPrint('NovelServices:getList-> ${e.toString()}');
      }
      return [];
    });
    return list;
  }
}
