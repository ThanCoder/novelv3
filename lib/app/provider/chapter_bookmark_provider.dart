import 'package:flutter/material.dart';
import 'package:novel_v3/app/dialogs/rename_dialog.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/services/index.dart';

class ChapterBookmarkProvider with ChangeNotifier {
  final List<ChapterBookMarkModel> _list = [];
  bool _isLoading = false;

  List<ChapterBookMarkModel> get getList => _list;
  bool get isLoading => _isLoading;

  Future<List<ChapterBookMarkModel>> initList() async {
    try {
      _isLoading = true;
      notifyListeners();

      final res = await ChapterBookmarkServices.instance
          .getList(novelPath: currentNovelNotifier.value!.path);

      _list.clear();
      _list.addAll(res);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('initList: ${e.toString()}');
    }
    return _list;
  }

  Future<bool> exists({required String chapter}) async {
    return _list.any((bm) => bm.chapter == chapter);
  }

  Future<void> toggle(BuildContext context,
      {required ChapterBookMarkModel bookmark, VoidCallback? callback}) async {
    if (await exists(chapter: bookmark.chapter)) {
      await delete(bookmark: bookmark);
    } else {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => RenameDialog(
          title: 'BookMark Title',
          onCancel: () {},
          onSubmit: (title) async {
            bookmark.title = title;
            await add(bookmark: bookmark);
            if (callback != null) {
              callback();
            }
          },
        ),
      );
    }
  }

  Future<void> add({required ChapterBookMarkModel bookmark}) async {
    try {
      _list.add(bookmark);

      //update
      await ChapterBookmarkServices.instance
          .setList(novelPath: currentNovelNotifier.value!.path, list: _list);

      notifyListeners();
    } catch (e) {
      debugPrint('add: ${e.toString()}');
    }
  }

  Future<void> update(
    BuildContext context, {
    required ChapterBookMarkModel bookmark,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RenameDialog(
        title: 'Update Title',
        renameText: bookmark.title,
        onCancel: () {},
        onSubmit: (title) async {
          try {
            bookmark.title = title;
            final res = _list.map((bm) {
              if (bm.chapter == bm.chapter) {
                bm = bookmark;
              }
              return bm;
            }).toList();
            _list.clear();
            _list.addAll(res);

            //update
            await ChapterBookmarkServices.instance.setList(
                novelPath: currentNovelNotifier.value!.path, list: _list);

            notifyListeners();
          } catch (e) {
            debugPrint('update: ${e.toString()}');
          }
        },
      ),
    );
  }

  Future<void> delete({required ChapterBookMarkModel bookmark}) async {
    try {
      final res = _list.where((bm) => bm.title != bookmark.title).toList();
      _list.clear();
      _list.addAll(res);

      //update
      await ChapterBookmarkServices.instance
          .setList(novelPath: currentNovelNotifier.value!.path, list: _list);

      notifyListeners();
    } catch (e) {
      debugPrint('delete: ${e.toString()}');
    }
  }
}
