import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/services/novel_services.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:than_pkg/extensions/string_extension.dart';

class NovelProvider extends ChangeNotifier {
  List<Novel> list = [];
  bool isLoading = false;
  Novel? currentNovel;

  Future<void> init({bool isUsedCache = true}) async {
    if (isUsedCache && list.isNotEmpty) return;
    isLoading = true;
    notifyListeners();

    list = await NovelServices.instance.getAll();

    isLoading = false;
    notifyListeners();
  }

  Future<void> setCurrentNovel(Novel novel) async {
    currentNovel = novel;
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  Future<void> add(Novel novel) async {
    list.insert(0, novel);
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  Future<void> update(Novel novel) async {
    String oldPath = novel.path;
    // check path == title
    if (novel.title != novel.path.getName()) {
      // update directory
      final oldDir = Directory(novel.path);
      final newDir = Directory('${oldDir.parent.path}/${novel.title}');
      await PathUtil.renameDir(oldDir: oldDir, newDir: newDir);
      // update new path
      novel = novel.copyWith(path: newDir.path);
    }
    // resave meta
    await novel.meta.save(novel.path);

    final index = list.indexWhere((e) => e.path == oldPath);
    if (index == -1) return;
    list[index] = novel;
    await Future.delayed(Duration.zero);
    notifyListeners();
  }
}
