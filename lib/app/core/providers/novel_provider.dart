import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/extensions/directory_extension.dart';
import 'package:novel_v3/app/core/extensions/novel_extension.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/services/novel_services.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelProvider extends ChangeNotifier {
  List<Novel> list = [];
  bool isLoading = false;
  Novel? currentNovel;
  // search result list
  List<Novel> searchResultList = [];
  void setSearchResultList(List<Novel> list) {
    searchResultList = list;
    notifyListeners();
  }

  void refersh() => notifyListeners();

  Future<void> init({bool isUsedCache = true}) async {
    if (isUsedCache && list.isNotEmpty) return;
    isLoading = true;
    notifyListeners();

    list = await NovelServices.getAll();
    // sort
    sortAsc = TRecentDB.getInstance.getBool(
      'novel-home-sort-sortAsc',
      def: false,
    );
    currentSortId = TRecentDB.getInstance.getInt(
      'novel-home-sort-sortId',
      def: TSort.getDateId,
    );
    await sort(currentSortId, sortAsc);

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
    if (index != -1) {
      list[index] = novel;
    }
    // set current
    currentNovel = novel;

    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  Future<void> deleteForever(Novel novel) async {
    final index = list.indexWhere((e) => e.path == novel.path);
    if (index == -1) return;
    list.removeAt(index);
    // remove search list
    final resultIndex = searchResultList.indexWhere(
      (e) => e.path == novel.path,
    );
    if (resultIndex == -1) return;
    searchResultList.removeAt(resultIndex);

    final dir = Directory(novel.path);
    if (dir.existsSync()) {
      await PathUtil.deleteDir(dir);
    }
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  Future<void> calculateSize({
    required bool Function() isCanceld,
    void Function(int total, int loaded, String message)? onProgress,
  }) async {
    try {
      final receivePort = ReceivePort();
      final pathList = list.map((e) => e.path).toList();

      await Isolate.spawn(calculatePathSizeIsolate, (
        receivePort.sendPort,
        pathList,
      ));

      int index = 0;
      await for (final message in receivePort) {
        index++;
        if (message is! Map) continue;
        if (isCanceld()) {
          receivePort.close();
          break;
        }
        if (message['done'] ?? false) {
          receivePort.close();
          break;
        }
        String path = message['path'] ?? '';
        int size = message['size'] ?? 0;
        if (path.isEmpty || size == 0) continue;

        // await Future.delayed(Duration(milliseconds: 600));

        // progress
        final novelIndex = list.indexWhere((e) => e.path == path);
        if (novelIndex == -1) continue;
        final novel = list[novelIndex];

        onProgress?.call(
          list.length,
          index,
          'Calculated Size: \n${novel.title}....',
        );
        novel.size ??= size;

        // print('index: $index - length: ${list.length}');
      }
    } catch (e) {
      debugPrint('[calculateSize]: ${e.toString()}');
    }
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

  // sort
  bool sortAsc = false;
  int currentSortId = TSort.getDateId;
  List<TSort> sortList = TSort.getDefaultList
    ..add(
      TSort(id: 1, title: 'Size', ascTitle: 'Smallest', descTitle: 'Biggest'),
    );

  Future<void> sort(int currentId, bool isAsc) async {
    sortAsc = isAsc;
    currentSortId = currentId;

    if (currentSortId == TSort.getDateId) {
      // date
      list.sortDate(isNewest: !sortAsc);
    }
    if (currentSortId == TSort.getTitleId) {
      // title
      list.sortTitle(aToZ: sortAsc);
    }
    if (currentSortId == 1) {
      await calculateSize(isCanceld: () => false);
      // size
      list.sortSize(isSmallest: sortAsc);
    }
    // set recent
    TRecentDB.getInstance.putBool('novel-home-sort-sortAsc', sortAsc);
    TRecentDB.getInstance.putInt('novel-home-sort-sortId', currentId);
    notifyListeners();
  }
}

Future<void> calculatePathSizeIsolate((SendPort, List<String>) args) async {
  final sendPort = args.$1;
  final pathList = args.$2;

  for (var path in pathList) {
    final dir = Directory(path);
    if (!dir.existsSync()) continue;
    sendPort.send({'path': path, 'size': await dir.getAllSize()});
  }
  sendPort.send({'done': true});
}
