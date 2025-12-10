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

    list = await NovelServices.getAll();

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

  Future<void> deleteForever(Novel novel) async {
    final index = list.indexWhere((e) => e.path == novel.path);
    if (index == -1) return;
    list.removeAt(index);
    final dir = Directory(novel.path);
    if (dir.existsSync()) {
      await PathUtil.deleteDir(dir);
    }
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  List<Novel> searchAuthor(String author) {
    return list.where((e) => e.meta.author == author).toList();
  }

  List<Novel> searchMC(String mc) {
    return list.where((e) => e.meta.mc == mc).toList();
  }

  List<Novel> searchTranslator(String translator) {
    return list.where((e) => e.meta.translator == translator).toList();
  }

  List<Novel> searchTag(String tag) {
    return list.where((e) => e.meta.tags.contains(tag)).toList();
  }

  List<String> get getAllTags {
    final res = list
        .map((e) => e.meta)
        .expand((e) => e.tags)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    res.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return res;
  }

  List<String> get getAllAuthors {
    final res = list
        .map((e) => e.meta.author)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    res.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return res;
  }

  List<String> get getAllMC {
    final res = list
        .map((e) => e.meta.mc)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    res.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return res;
  }

  List<String> get getAllTranslator {
    final res = list
        .map((e) => e.meta.translator)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    res.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return res;
  }
}
