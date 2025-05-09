import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/riverpods/states/bookmark_state.dart';

import '../../models/novel_model.dart';
import '../../services/bookmark_services.dart';

class BookmarkNotifier extends StateNotifier<BookmarkState> {
  BookmarkNotifier() : super(BookmarkState.init());

  Future<void> initList() async {
    final res = await BookmarkServices.instance.getNovelBookmarkList();
    state = state.copyWith(list: res);
  }

  Future<void> add(NovelModel novel) async {
    state.list.insert(0, novel);
    //db
    await BookmarkServices.instance.setNovelBookmarkList(list: state.list);
    state = state.copyWith(isExists: true);
  }

  Future<void> remove(NovelModel novel) async {
    state.list = state.list.where((nv) => nv.title != novel.title).toList();
    //db
    await BookmarkServices.instance.setNovelBookmarkList(list: state.list);
    state = state.copyWith(isExists: false, list: state.list);
  }

  Future<void> toggle(NovelModel novel) async {
    if (checkExists(novel)) {
      await remove(novel);
    } else {
      await add(novel);
    }
  }

  bool checkExists(NovelModel novel) {
    final res = state.list.where((nv) => nv.title == novel.title);
    if (res.isNotEmpty) {
      state = state.copyWith(isExists: true);
      return true;
    }
    state = state.copyWith(isExists: false);
    return false;
  }
}
