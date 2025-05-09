// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../models/index.dart';

class BookmarkState {
  bool isLoading;
  List<NovelModel> list;
  bool isExists;
  BookmarkState({
    required this.isLoading,
    required this.list,
    this.isExists = false,
  });

  factory BookmarkState.init() => BookmarkState(isLoading: false, list: []);

  BookmarkState copyWith({
    bool? isLoading,
    List<NovelModel>? list,
    bool? isExists,
  }) {
    return BookmarkState(
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
      isExists: isExists ?? this.isExists,
    );
  }

  
}
