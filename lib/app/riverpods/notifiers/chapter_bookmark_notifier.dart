import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/my_libs/text_reader/chapter_bookmark_model.dart';
import 'package:novel_v3/app/riverpods/states/chapter_bookmark_state.dart';
import 'package:novel_v3/app/services/bookmark_services.dart';

class ChapterBookmarkNotifier extends StateNotifier<ChapterBookmarkState> {
  ChapterBookmarkNotifier() : super(ChapterBookmarkState.init());

  Future<void> initList(String novelPath) async {
    state = state.copyWith(isLoading: true);
    final res =
        await BookmarkServices.instance.getChapterBookmarkList(novelPath);
    state = state.copyWith(list: res, isLoading: false);
  }

  Future<void> add(String novelPath, ChapterBookmarkModel book) async {
    state.list.insert(0, book);
    state = state.copyWith(list: state.list);
    //db
    await BookmarkServices.instance
        .setChapterBookmarkList(novelPath, list: state.list);
  }

  Future<void> remove(String novelPath, ChapterBookmarkModel book) async {
    final res = state.list.where((bm) => bm.chapter != book.chapter).toList();
    state = state.copyWith(list: res);
    //db
    await BookmarkServices.instance
        .setChapterBookmarkList(novelPath, list: state.list);
  }

  Future<void> update(String novelPath, ChapterBookmarkModel book) async {
    final index = state.list.indexWhere((bm) => bm.chapter == book.chapter);
    if (index == -1) return;
    state.list[index] = book;
    state = state.copyWith(list: state.list);
    //db
    await BookmarkServices.instance
        .setChapterBookmarkList(novelPath, list: state.list);
  }

  Future<void> toggle(String novelPath, ChapterBookmarkModel book) async {
    if (isExists(book.chapter)) {
      await remove(novelPath, book);
    } else {
      await add(novelPath, book);
    }
  }

  bool isExists(int chapterNumber) {
    final res = state.list.where((book) => book.chapter == chapterNumber);
    if (res.isNotEmpty) return true;
    return false;
  }
}
