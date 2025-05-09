import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/riverpods/states/recent_state.dart';
import 'package:novel_v3/app/services/recent_services.dart';

class RecentNotifier extends StateNotifier<RecentState> {
  RecentNotifier() : super(RecentState.init());

  Future<void> initList() async {
    state = state.copyWith(isLoading: true);
    final res = await RecentServices.getList();
    state = state.copyWith(list: res, isLoading: false);
  }

  Future<void> add(NovelModel novel) async {
    if (state.list.isEmpty) {
      state.list.insert(0, novel);
      state = state.copyWith(list: state.list);
      await RecentServices.setList(list: state.list);
      return;
    }
    //ထပ်နေလား စစ်မယ်
    final res = state.list.where((nv) => nv.title != novel.title).toList();
    state.list.clear();
    state.list.addAll(res);
    state.list.insert(0, novel);
    state = state.copyWith(list: state.list);
    await RecentServices.setList(list: state.list);
  }
}
