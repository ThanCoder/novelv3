import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_list_cubit.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/services/novel_services.dart';

class NovelDetailState {
  final Novel? currentNovel;
  final bool isLoading;
  final String? errorMessage;

  const NovelDetailState({
    this.currentNovel,
    required this.isLoading,
    this.errorMessage,
  });
  factory NovelDetailState.initState({bool isLoading = true}) {
    return NovelDetailState(isLoading: isLoading);
  }

  NovelDetailState copyWith({
    Novel? currentNovel,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NovelDetailState(
      currentNovel: currentNovel ?? this.currentNovel,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class NovelDetailCubit extends Cubit<NovelDetailState> {
  final NovelServices novelServices;
  final NovelListCubit novelListCubit;

  NovelDetailCubit({required this.novelServices, required this.novelListCubit})
    : super(NovelDetailState.initState(isLoading: false));

  Future<void> setCurrentNovel(Novel novel) async {
    emit(state.copyWith(currentNovel: novel, isLoading: false));
    await Future.delayed(Duration.zero);
  }

  Future<Novel?> getNovelById(String id) async {
    try {
      if (state.isLoading) return null;
      if (state.currentNovel != null && state.currentNovel!.id == id) {
        return state.currentNovel;
      }

      emit(NovelDetailState.initState());

      final novel = await novelServices.getById(id);
      emit(state.copyWith(isLoading: false, currentNovel: novel));
      return novel;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
      return null;
    }
  }

  Future<Novel?> updateNovel(String id, Novel novel) async {
    try {
      if (state.isLoading) return null;

      emit(state.copyWith(isLoading: true, errorMessage: null));
      await novelServices.updateNovel(id, novel);
      // update list
      final index = novelListCubit.state.list.indexWhere((e) => e.id == id);
      if (index != -1) {
        // list ထဲမှာ ရှိနေရင်
        final list = novelListCubit.state.list;
        list[index] = novel.copyWith(size: list[index].size);
        novelListCubit.setList(list);
      }
      emit(state.copyWith(isLoading: false, currentNovel: novel));
      return novel;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return null;
    }
  }
}
