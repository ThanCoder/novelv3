import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/core/databases/chapter_db.dart';
import 'package:novel_v3/core/extensions/chapter_extension.dart';
import 'package:novel_v3/core/models/chapter.dart';

class ChapterListCubit extends Cubit<ChapterListState> {
  final NovelDetailCubit novelDetailCubit;
  ChapterListCubit({required this.novelDetailCubit})
    : super(ChapterListState.createState());

  Future<void> fetchList({bool isCached = true}) async {
    try {
      if (state.isLoading) return;

      //delay
      // await Future.delayed(Duration(seconds: 3));

      final novel = novelDetailCubit.state.currentNovel;
      if (novel == null) return;

      if (novel.id == state.currentNovelId &&
          isCached &&
          state.list.isNotEmpty) {
        return;
      }

      emit(
        ChapterListState.createState(isLoading: true, sortAsc: state.sortAsc),
      );
      //cache clean up
      await ChapterDB.clearAll();
      final list = await ChapterDB.getAll(novel.id);

      // sort
      list.sortChapterNumber(isSort: state.sortAsc);

      emit(
        state.copyWith(isLoading: false, list: list, currentNovelId: novel.id),
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

  Future<String?> getChapterContent(int number) async {
    final content = await ChapterDB.getContent(
      number,
      novelDetailCubit.state.currentNovel!.id,
    );
    return content?.content;
  }

  Future<int> add(Chapter chapter) async {
    return await ChapterDB.add(
      chapter,
      novelId: novelDetailCubit.state.currentNovel!.id,
    );
  }

  Future<void> update(Chapter chapter) async {
    await ChapterDB.update(
      chapter,
      novelId: novelDetailCubit.state.currentNovel!.id,
    );
  }

  Future<void> delete(Chapter chapter) async {
    await ChapterDB.delete(
      chapter,
      novelId: novelDetailCubit.state.currentNovel!.id,
    );
    final index = state.list.indexWhere((e) => e.number == chapter.number);
    final list = state.list;
    list.removeAt(index);
    emit(state.copyWith(list: list));
  }

  bool existsChapterNumber(int number) {
    final index = state.list.indexWhere((e) => e.number == number);
    return index != -1;
  }

  ///
  /// ###  return (isAdded, isUpdated);
  ///
  Future<(bool, bool)> addOrUpdate(Chapter chapter) async {
    final index = state.list.indexWhere((e) => e.number == chapter.number);
    final list = state.list;
    bool isUpdated = false;
    bool isAdded = false;

    if (index == -1) {
      //new
      await add(chapter);
      list.add(chapter);
      isAdded = true;
    } else {
      //update
      final updatedChapter = list[index].copyWith(
        title: chapter.title,
        number: chapter.number,
        content: chapter.content,
      );
      await update(updatedChapter);
      list[index] = updatedChapter;
      isUpdated = true;
    }
    list.sortChapterNumber(isSort: state.sortAsc);
    emit(state.copyWith(list: list));
    return (isAdded, isUpdated);
  }

  void sort(bool sortAsc) {
    final list = state.list;
    list.sortChapterNumber(isSort: sortAsc);

    emit(state.copyWith(list: list, sortAsc: sortAsc));
  }

  ReadedResponse getReadedResponse() {
    // readed အတွက်
    Chapter? readedChapter;
    Chapter? readedPrevChapter;
    Chapter? readedNextChapter;

    final list = List.of(state.list);

    if (list.isNotEmpty) {
      final sortList = List.of(list);
      sortList.sortChapterNumber();
      final index = list.indexWhere(
        (e) => e.number == novelDetailCubit.state.currentNovel!.meta.readed,
      );
      if (index != -1) {
        readedChapter = list[index];
        // Previous Chapter: ရှေ့မှာ အခန်းကျန်သေးလား စစ်တာ (Index 0 ထက် ကြီးရမယ်)
        if (index > 0) {
          readedPrevChapter = list[index - 1];
        }

        // Next Chapter: နောက်မှာ အခန်းကျန်သေးလား စစ်တာ
        // (Index က နောက်ဆုံးခန်း မဟုတ်ရဘူး၊ ဆိုလိုတာက length - 1 ထက် ငယ်ရမယ်)
        if (index < list.length - 1) {
          readedNextChapter = list[index + 1];
        }
      }
    }
    return ReadedResponse(
      readedChapter: readedChapter,
      readedNextChapter: readedNextChapter,
      readedPrevChapter: readedPrevChapter,
    );
  }
}

class ChapterListState {
  final String currentNovelId;
  final List<Chapter> list;
  final bool isLoading;
  final String? errorMessage;
  final bool sortAsc;

  const ChapterListState({
    required this.currentNovelId,
    required this.list,
    required this.isLoading,
    this.errorMessage,
    this.sortAsc = true,
  });

  factory ChapterListState.createState({
    bool isLoading = false,
    bool sortAsc = true,
  }) {
    return ChapterListState(
      list: [],
      isLoading: isLoading,
      currentNovelId: '-1',
      errorMessage: null,
      sortAsc: sortAsc,
    );
  }

  ChapterListState copyWith({
    String? currentNovelId,
    List<Chapter>? list,
    bool? isLoading,
    String? errorMessage,
    bool? sortAsc,
  }) {
    return ChapterListState(
      currentNovelId: currentNovelId ?? this.currentNovelId,
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      sortAsc: sortAsc ?? this.sortAsc,
    );
  }
}

class ReadedResponse {
  final Chapter? readedChapter;
  final Chapter? readedPrevChapter;
  final Chapter? readedNextChapter;

  const ReadedResponse({
    this.readedChapter,
    this.readedPrevChapter,
    this.readedNextChapter,
  });
}
