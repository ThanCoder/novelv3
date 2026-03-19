import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/core/extensions/chapter_extension.dart';
import 'package:novel_v3/core/models/chapter_bookmark.dart';
import 'package:novel_v3/core/services/chapter_bookmark_services.dart';

class ChapterBookmarkListCubit extends Cubit<ChapterBookmarkListCubitState> {
  final chapterBookmarkServices = ChapterBookmarkServices();
  final NovelDetailCubit novelDetailCubit;

  ChapterBookmarkListCubit({required this.novelDetailCubit})
    : super(ChapterBookmarkListCubitState.init());

  String novelPath() => novelDetailCubit.state.currentNovel!.path;

  Future<void> fetch() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
      final list = await chapterBookmarkServices.getAll(novelPath());
      // sort
      list.sortChapterNumber();

      emit(state.copyWith(isLoading: false, list: list));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, list: [], errorMessage: e.toString()),
      );
    }
  }

  Future<void> toggle(ChapterBookmark bookmark) async {
    final index = state.list.indexWhere((e) => e.chapter == bookmark.chapter);
    final list = state.list;
    if (index == -1) {
      //add
      list.add(bookmark);
    } else {
      //remove
      list.removeAt(index);
    }
    // sort
    list.sortChapterNumber();

    emit(state.copyWith(list: list));

    await chapterBookmarkServices.setAll(list, novelPath());
  }

  Future<void> removeNumber(int chapterNumber) async {
    final index = state.list.indexWhere((e) => e.chapter == chapterNumber);
    if (index == -1) return;
    final list = state.list;
    list.removeAt(index);
    emit(state.copyWith(list: list));

    await chapterBookmarkServices.setAll(list, novelPath());
  }

  bool isExists(int chapterNumber) {
    final index = state.list.indexWhere((e) => e.chapter == chapterNumber);
    return index != -1;
  }
}

class ChapterBookmarkListCubitState {
  final List<ChapterBookmark> list;
  final bool isLoading;
  final String errorMessage;

  const ChapterBookmarkListCubitState({
    required this.list,
    required this.isLoading,
    required this.errorMessage,
  });

  factory ChapterBookmarkListCubitState.init({bool isLoading = false}) {
    return ChapterBookmarkListCubitState(
      list: [],
      isLoading: isLoading,
      errorMessage: '',
    );
  }

  ChapterBookmarkListCubitState copyWith({
    List<ChapterBookmark>? list,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChapterBookmarkListCubitState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
