// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:novel_v3/app/models/novel_model.dart';

class NovelState {
  List<NovelModel> list;
  NovelModel? novel;
  bool isLoading;
  NovelState({
    required this.list,
    required this.isLoading,
    this.novel,
  });

  factory NovelState.init() {
    return NovelState(list: [], isLoading: false);
  }

  NovelState copyWith({
    List<NovelModel>? list,
    bool? isLoading,
    NovelModel? novel,
  }) {
    return NovelState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
      novel: novel ?? this.novel,
    );
  }
}
