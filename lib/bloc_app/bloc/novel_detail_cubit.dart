import 'package:flutter_bloc/flutter_bloc.dart';
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
  factory NovelDetailState.initState() {
    return NovelDetailState(isLoading: false);
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

  NovelDetailCubit({required this.novelServices})
    : super(NovelDetailState.initState());

  Future<Novel?> getNovelById(String id) async {
    try {
      if (state.isLoading) return null;

      emit(state.copyWith(isLoading: true, errorMessage: null));
      final novel = await novelServices.getById(id);
      emit(state.copyWith(isLoading: false, currentNovel: novel));
      return novel;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return null;
    }
  }
  Future<Novel?> updateNovel(String id,Novel novel) async {
    try {
      if (state.isLoading) return null;

      emit(state.copyWith(isLoading: true, errorMessage: null));
      final novel = await novelServices.getById(id);
      emit(state.copyWith(isLoading: false, currentNovel: novel));
      return novel;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return null;
    }
  }
}
