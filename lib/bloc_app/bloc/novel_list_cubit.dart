import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/core/extensions/novel_extension.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/services/novel_services.dart';

class NovelListState {
  final List<Novel> list;
  final bool isLoading;
  final String? errorMessage;

  const NovelListState({
    required this.list,
    required this.isLoading,
    required this.errorMessage,
  });
  factory NovelListState.initState() {
    return NovelListState(list: [], isLoading: false, errorMessage: null);
  }

  NovelListState copyWith({
    List<Novel>? list,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NovelListState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class NovelListCubit extends Cubit<NovelListState> {
  final NovelServices novelServices;
  NovelListCubit(this.novelServices) : super(NovelListState.initState());

  Future<void> fetchNovel() async {
    try {
      if (state.isLoading) return;

      emit(state.copyWith(isLoading: true, errorMessage: null));
      // await Future.delayed(Duration(seconds: 2));
      final list = await novelServices.getAll();

      // sort
      list.sortDate(isNewest: true);

      emit(state.copyWith(list: list, isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void setList(List<Novel> list) {
    emit(state.copyWith(list: list));
  }
}
