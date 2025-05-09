// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:novel_v3/app/models/chapter_bookmark_model.dart';

class ChapterBookmarkState {
  List<ChapterBookmarkModel> list;
  bool isLoading;
  ChapterBookmarkState({
    required this.list,
    this.isLoading = false,
  });

  factory ChapterBookmarkState.init() => ChapterBookmarkState(list: []);

  ChapterBookmarkState copyWith({
    List<ChapterBookmarkModel>? list,
    bool? isLoading,
  }) {
    return ChapterBookmarkState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
