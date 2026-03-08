import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/services/chapter_services.dart';

class ChapterListState {
  final String currentNovelId;
  final List<Chapter> list;
  final bool isLoading;
  final String? errorMessage;

  const ChapterListState({
    required this.currentNovelId,
    required this.list,
    required this.isLoading,
    this.errorMessage,
  });

  factory ChapterListState.createState() {
    return ChapterListState(list: [], isLoading: false, currentNovelId: '-1');
  }

  ChapterListState copyWith({
    String? currentNovelId,
    List<Chapter>? list,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChapterListState(
      currentNovelId: currentNovelId ?? this.currentNovelId,
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ChapterListCubit extends Cubit<ChapterListState> {
  final ChapterServices chapterServices;
  ChapterListCubit(this.chapterServices)
    : super(ChapterListState.createState());

  Future<void> fetchList(String novelId, {bool isCached = true}) async {
    try {
      if (state.isLoading) return;

      if (novelId == state.currentNovelId &&
          isCached &&
          state.list.isNotEmpty) {
        return;
      }

      emit(state.copyWith(isLoading: true, errorMessage: null));

      final list = await chapterServices.getAll(novelId);

      emit(
        state.copyWith(isLoading: false, list: list, currentNovelId: novelId),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          currentNovelId: '-1',
        ),
      );
    }
  }
}
