import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/services/novel_bookmark_services.dart';

class NovelBookmarkListCubit extends Cubit<NovelBookmarkListCubitState> {
  final novelBookmarkServices = NovelBookmarkServices();

  NovelBookmarkListCubit() : super(NovelBookmarkListCubitState.init());

  Future<void> fetch() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
      final list = await novelBookmarkServices.getAllNovelList();
      // sort
      emit(state.copyWith(isLoading: false, list: list));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, list: [], errorMessage: e.toString()),
      );
    }
  }

  Future<void> toggle(Novel novel) async {
    final index = state.list.indexWhere((e) => e.id == novel.id);
    final list = state.list;
    if (index == -1) {
      //add
      list.insert(0, novel);
    } else {
      //remove
      list.removeAt(index);
    }

    emit(state.copyWith(list: list));

    await novelBookmarkServices.setListNovelList(list);
  }

  Future<void> remove(Novel novel) async {
    final index = state.list.indexWhere((e) => e.id == novel.id);
    if (index == -1) return;
    final list = state.list;
    list.removeAt(index);
    emit(state.copyWith(list: list));

    await novelBookmarkServices.setListNovelList(list);
  }

  bool isExists(Novel novel) {
    final index = state.list.indexWhere((e) => e.id == novel.id);
    return index != -1;
  }
}

class NovelBookmarkListCubitState {
  final List<Novel> list;
  final bool isLoading;
  final String errorMessage;

  const NovelBookmarkListCubitState({
    required this.list,
    required this.isLoading,
    required this.errorMessage,
  });

  factory NovelBookmarkListCubitState.init({bool isLoading = false}) {
    return NovelBookmarkListCubitState(
      list: [],
      isLoading: isLoading,
      errorMessage: '',
    );
  }

  NovelBookmarkListCubitState copyWith({
    List<Novel>? list,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NovelBookmarkListCubitState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
