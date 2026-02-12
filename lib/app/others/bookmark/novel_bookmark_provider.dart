import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/providers/novel_provider.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_services.dart';
import 'package:provider/provider.dart';

class NovelBookmarkProvider with ChangeNotifier {
  List<NovelBookmark> list = [];
  List<Novel> novelList = [];
  bool isLoading = false;

  Future<void> init(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    list = await NovelBookmarkServices.getAll();
    if (!context.mounted) return;
    await parseNovelList(context);

    isLoading = false;
    notifyListeners();
  }

  Future<void> parseNovelList(BuildContext context) async {
    novelList.clear();
    final res = context.read<NovelProvider>().list;
    for (var bookmark in list) {
      final index = res.indexWhere((e) => e.meta.title == bookmark.title);
      if (index == -1) continue;
      novelList.add(res[index]);
    }
    notifyListeners();
  }

  Future<void> toggle(
    NovelBookmark bookmark, {
    required BuildContext context,
  }) async {
    if (isExists(bookmark.title)) {
      await remove(bookmark, context: context);
    } else {
      await add(bookmark, context: context);
    }
  }

  Future<void> add(
    NovelBookmark bookmark, {
    required BuildContext context,
  }) async {
    list.insert(0, bookmark);
    await parseNovelList(context);
    await NovelBookmarkServices.setList(list);
    notifyListeners();
  }

  Future<void> remove(
    NovelBookmark bookmark, {
    required BuildContext context,
  }) async {
    if (list.isEmpty) return;
    final index = list.indexWhere((e) => e.title == bookmark.title);
    if (index != -1) {
      list.removeAt(index);
    }
    await parseNovelList(context);
    await NovelBookmarkServices.setList(list);
    notifyListeners();
  }

  bool isExists(String title) {
    if (list.isEmpty) return false;
    final index = list.indexWhere((e) => e.title == title);
    return index != -1;
  }
}
