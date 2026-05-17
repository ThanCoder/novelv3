import 'dart:isolate';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/core/databases/chapter_db_manager.dart';
import 'package:novel_v3/core/extensions/novel_extension.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/models/novel_meta.dart';
import 'package:novel_v3/core/services/novel_services.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelListCubit extends Cubit<NovelListState> {
  final NovelServices novelServices;
  NovelListCubit(this.novelServices) : super(NovelListState.initState());

  static List<TSort> sortList = [
    TSort(id: 1, title: 'Title', ascTitle: 'A-Z', descTitle: 'Z-A'),
    TSort(id: 2, title: 'Size', ascTitle: 'Smallest', descTitle: 'Biggest'),
    TSort(id: 3, title: 'Date', ascTitle: 'Newest', descTitle: 'Oldest'),
    TSort(id: 4, title: 'Adult', ascTitle: 'isAdult', descTitle: 'Not Adult'),
    TSort(
      id: 5,
      title: 'Completed',
      ascTitle: 'isCompleted',
      descTitle: 'OnGoing',
    ),
  ];

  Future<void> fetchNovel() async {
    try {
      if (state.isLoading) return;

      emit(NovelListState.initState(isLoading: true));
      // await Future.delayed(Duration(seconds: 2));
      ChapterDBManager.removeAllDB();
      final list = await novelServices.getAll();

      emit(state.copyWith(list: list, isLoading: false, isInit: false));

      sort();
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          isLoading: false,
          isInit: false,
        ),
      );
    }
  }

  void setList(List<Novel> list) {
    emit(state.copyWith(list: list));
  }

  Future<void> update(Novel novel) async {
    final index = state.list.indexWhere((e) => e.id == novel.id);
    if (index == -1) return;
    // update services
    await novelServices.updateNovel(novel.id, novel);

    final list = state.list;
    list.removeAt(index);
    list.insert(0, novel);
    emit(state.copyWith(list: list));
  }

  Future<void> delete(Novel novel) async {
    final index = state.list.indexWhere((e) => e.id == novel.id);
    if (index == -1) return;
    // update services
    await novelServices.deleteNovel(novel.id);

    final list = state.list;
    list.removeAt(index);
    emit(state.copyWith(list: list));
  }

  Future<Novel> createNewNovel({String title = 'Untitled'}) async {
    final novel = await novelServices.createNovel(
      meta: NovelMeta.create(title: title),
    );
    final list = state.list;
    list.insert(0, novel);
    emit(state.copyWith(list: list));
    return novel;
  }

  void addNew(Novel novel) {
    final list = state.list;
    list.insert(0, novel);
    emit(state.copyWith(list: list));
  }

  bool isExists(String title) {
    final index = state.list.indexWhere((e) => e.meta.title == title);
    return index != -1;
  }

  void refreshState() async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(Duration(milliseconds: 600));
    emit(state.copyWith(isLoading: false));
  }

  void setSort(int sortId, bool sortAsc) {
    emit(state.copyWith(sortId: sortId, sortAsc: sortAsc, isLoading: false));
    // set recent
    TRecentDB.getInstance.putInt('novel-list-sort-id', sortId);
    TRecentDB.getInstance.putBool('novel-list-sort-asc', sortAsc);
  }

  void sort() async {
    List<Novel> list = state.list.toList();

    if (state.sortId == 1) {
      list.sortTitle(aToZ: state.sortAsc);
    }
    if (state.sortId == 2) {
      emit(state.copyWith(isLoading: true));
      list = await _calcuteNovelSize(list);
      list.sortSize(isSmallest: state.sortAsc);
      emit(state.copyWith(isLoading: false, list: list));
    }
    if (state.sortId == 3) {
      list.sortDate(isNewest: state.sortAsc);
    }
    if (state.sortId == 4) {
      list.sortAdult(isAdult: state.sortAsc);
    }
    if (state.sortId == 5) {
      list.sortCompleted(isCompleted: state.sortAsc);
    }
    emit(state.copyWith(list: list));
  }

  List<String> allTags() {
    Set<String> tags = {};
    for (var novel in state.list) {
      tags.addAll(novel.meta.tags);
    }
    return tags.toList();
  }
}

class NovelListState {
  final List<Novel> list;
  final bool isLoading;
  final String errorMessage;
  final int sortId;
  final bool sortAsc;
  final bool isInit;

  const NovelListState({
    required this.list,
    required this.isLoading,
    required this.errorMessage,
    required this.sortId,
    required this.sortAsc,
    required this.isInit,
  });

  factory NovelListState.initState({
    bool isLoading = false,
    bool isInit = true,
  }) {
    return NovelListState(
      list: [],
      isLoading: isLoading,
      isInit: isInit,
      errorMessage: '',
      sortId: TRecentDB.getInstance.getInt('novel-list-sort-id', def: 3),
      sortAsc: TRecentDB.getInstance.getBool('novel-list-sort-asc', def: true),
    );
  }

  NovelListState copyWith({
    List<Novel>? list,
    bool? isLoading,
    String? errorMessage,
    int? sortId,
    bool? sortAsc,
    bool? isInit,
  }) {
    return NovelListState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      sortId: sortId ?? this.sortId,
      sortAsc: sortAsc ?? this.sortAsc,
      isInit: isInit ?? this.isInit,
    );
  }
}

Future<List<Novel>> _calcuteNovelSize(List<Novel> list) async {
  return await Isolate.run(() async {
    final results = <Novel>[];
    for (var no in list) {
      await no.getAllSize();
      results.add(no);
    }
    return results;
  });
}
