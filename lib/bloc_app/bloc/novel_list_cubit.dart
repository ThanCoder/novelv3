import 'package:flutter_bloc/flutter_bloc.dart';
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
    TSort(id: 3, title: 'Added', ascTitle: 'Newest', descTitle: 'Oldest'),
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
      final list = await novelServices.getAll();

      // sort
      if (state.sortId == 1) {
        state.list.sortTitle(aToZ: state.sortAsc);
      }
      if (state.sortId == 2) {
        state.list.sortSize(isSmallest: state.sortAsc);
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

      emit(state.copyWith(list: list, isLoading: false, isInit: false));
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

  void sort(int sortId, bool sortAsc) {
    final list = state.list;
    if (sortId == 1) {
      state.list.sortTitle(aToZ: sortAsc);
    }
    if (sortId == 2) {
      state.list.sortSize(isSmallest: sortAsc);
    }
    if (sortId == 3) {
      list.sortDate(isNewest: sortAsc);
    }
    if (sortId == 4) {
      list.sortAdult(isAdult: sortAsc);
    }
    if (sortId == 5) {
      list.sortCompleted(isCompleted: sortAsc);
    }
    emit(state.copyWith(list: list, sortId: sortId, sortAsc: sortAsc));
    // set recent
    TRecentDB.getInstance.putInt('novel-list-sort-id', sortId);
    TRecentDB.getInstance.putBool('novel-list-sort-asc', sortAsc);
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
