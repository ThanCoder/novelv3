import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/riverpods/states/novel_state.dart';
import 'package:novel_v3/app/services/novel_services.dart';

import '../../models/index.dart';

class NovelNotifier extends StateNotifier<NovelState> {
  NovelNotifier() : super(NovelState.init());

  NovelModel? get getCurrent => state.novel;
  List<NovelModel> get getList => state.list;

  bool isExists(String title) {
    final res = state.list.where((e) => e.title == title);
    if (res.isNotEmpty) return true;
    return false;
  }

  Future<void> initList({bool isReset = false}) async {
    if (!isReset && state.list.isNotEmpty) {
      return;
    }
    state = state.copyWith(isLoading: true, list: []);
    final res = await NovelServices.instance.getList();
    state = state.copyWith(isLoading: false, list: res);
  }


  Future<void> setCurrent(NovelModel novel, {bool isFullInfo = true}) async {
    try {
      if (isFullInfo) {
        novel = NovelModel.fromPath(novel.path, isFullInfo: true);
        state = state.copyWith(
            novel: novel);
      }
      // change index
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void insertUI(NovelModel novel) {
    state.list.insert(0, novel);
    state = state.copyWith(list: state.list);
  }

  void removeUI(NovelModel novel) {
    state = state.copyWith(
      list: state.list.where((nv) => nv.title != novel.title).toList(),
    );
  }

  void refreshCurrent() {
    if (state.novel == null) return;
    state = state.copyWith(
        novel: NovelModel.fromPath(
      state.novel!.path,
      isFullInfo: true,
    ));
  }

  void listClear() {
    state = state.copyWith(list: []);
  }
}
