import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/riverpods/states/chapter_state.dart';

import '../../models/chapter_model.dart';
import '../../services/index.dart';

class ChapterNotifier extends StateNotifier<ChapterState> {
  ChapterNotifier() : super(ChapterState.init());

  Future<void> initList({
    bool isReset = false,
    required String novelPath,
  }) async {
    if (!isReset && state.list.isNotEmpty) {
      return;
    }
    state = state.copyWith(isLoading: true);
    final res = await ChapterServices.instance.getList(novelPath: novelPath);
    state = state.copyWith(novelPath: novelPath, isLoading: false, list: res);
  }

  void update(ChapterModel chapter) {
    final res = state.list.map((ch) {
      if (ch.number == chapter.number) {
        return chapter;
      }
      return ch;
    }).toList();
    state = state.copyWith(list: res);
  }

  void delete(ChapterModel chapter) {
    final res = state.list.where((ch) => ch.number != chapter.number).toList();
    state = state.copyWith(list: res);

    chapter.delete();
  }

  void listClear() {
    state = state.copyWith(list: []);
  }

  void reversedList() {
    final res = state.list.reversed.toList();
    state = state.copyWith(list: res);
  }

  void add(ChapterModel chapter) {
    state.list.add(chapter);
    state = state.copyWith(list: state.list);
  }
}
