import 'package:chapters_db/chapters_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/core/databases/chapter_db_manager.dart';
import 'package:novel_v3/core/db_migration.dart';
import 'package:novel_v3/core/extensions/chapter_extension.dart';
import 'package:novel_v3/core/models/chapter.dart';

class ChapterListCubit extends Cubit<ChapterListState> {
  final NovelDetailCubit novelDetailCubit;
  ChapterListCubit({required this.novelDetailCubit})
    : super(ChapterListState.createState());

  Future<void> fetchList(BuildContext context, {bool isCached = true}) async {
    try {
      if (state.isLoading) return;

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
      if (DbMigration.isDBMigration(novel.id)) {
        ChapterDBManager.removeDB(novel.id);
        await DbMigration.migrate(context, novel.id);
      }
      // cache ပိတ်ထားရင် db cache ကိုဖျက်မယ်
      if (!isCached) {
        await ChapterDBManager.removeDB(novel.id);
      }
      final box = await ChapterDBManager.getBox(novel.id);
      final list = <Chapter>[];
      await for (var info in box.getAllStream()) {
        list.add(Chapter.fromInfo(info, novelId: novel.id));
      }
      // print(list);
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
    try {
      final index = state.list.indexWhere((e) => e.number == number);
      if (index != -1) {
        final ch = state.list[index];
        if (ch.info == null) {
          return ch.content;
        }
        final data = await ch.info!.getContent();
        return data.body;
      }
    } catch (e) {
      debugPrint('[ChapterListCubit:getChapterContent]: $e');
    }
    return null;
  }

  Future<void> add(Chapter chapter) async {
    try {
      final box = await ChapterDBManager.getBox(state.currentNovelId);
      box.add(
        DefaultChapter(
          title: chapter.title,
          chapterNumber: chapter.number,
          body: chapter.content!,
        ),
      );
      final list = state.list;
      list.add(chapter);
      emit(state.copyWith(list: list));
    } catch (e) {
      debugPrint('[ChapterListCubit:add]: $e');
    }
  }

  Future<void> update(int id, Chapter chapter) async {
    final box = await ChapterDBManager.getBox(state.currentNovelId);
    box.updateById(
      id,
      DefaultChapter(
        id: id,
        title: chapter.title,
        chapterNumber: chapter.number,
        body: chapter.content!,
      ),
    );
  }

  Future<void> delete(Chapter chapter) async {
    final box = await ChapterDBManager.getBox(state.currentNovelId);

    final isDeleted = await box.deleteById(chapter.autoId);
    if (isDeleted) {
      final index = state.list.indexWhere((e) => e.number == chapter.number);
      final list = state.list;
      list.removeAt(index);
      emit(state.copyWith(list: list));
    }
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
      isAdded = true;
    } else {
      //update
      list[index] = chapter;
      await update(chapter.autoId, chapter);
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
