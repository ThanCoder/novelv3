import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_list_cubit.dart';
import 'package:novel_v3/bloc_app/ui/main/novel_type_tabbar.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/services/novel_bookmark_services.dart';

class NovelTypeTabbarCubit extends Cubit<NovelTypes> {
  final NovelListCubit novelListCubit;
  final NovelBookmarkServices novelBookmarkServices;
  final List<Novel> _allNovelList = [];

  NovelTypeTabbarCubit({
    required this.novelListCubit,
    required this.novelBookmarkServices,
  }) : super(NovelTypes.latest);

  void setCurrent(NovelTypes type) async {
    if (type == state) return;

    emit(type);

    // book mark
    if (type == NovelTypes.bookmark) {
      final list = await novelBookmarkServices.getAllNovelList();
      novelListCubit.setList(list);
      return;
    }

    if (type == NovelTypes.latest) {
      await novelListCubit.fetchNovel();
      _allNovelList.clear();
      _allNovelList.addAll(novelListCubit.state.list);
      return;
    }
    if (_allNovelList.isEmpty && novelListCubit.state.list.isNotEmpty) {
      _allNovelList.addAll(novelListCubit.state.list);
    }

    final list = _allNovelList;

    if (type == NovelTypes.adult) {
      novelListCubit.setList(list.where((e) => e.meta.isAdult).toList());
      return;
    }
    if (type == NovelTypes.notAdult) {
      novelListCubit.setList(list.where((e) => !e.meta.isAdult).toList());
      return;
    }
    if (type == NovelTypes.onGoing) {
      novelListCubit.setList(list.where((e) => !e.meta.isCompleted).toList());
      return;
    }
    if (type == NovelTypes.completed) {
      novelListCubit.setList(list.where((e) => e.meta.isCompleted).toList());
      return;
    }
  }
}
