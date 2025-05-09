// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../models/index.dart';

class ChapterState {
  final List<ChapterModel> list;
  bool isLoading;
  String novelPath;
  ChapterState({
    required this.list,
    this.isLoading = false,
    this.novelPath = '',
  });

  factory ChapterState.init() => ChapterState(list: []);
  

  ChapterState copyWith({
    List<ChapterModel>? list,
    bool? isLoading,
    String? novelPath,
  }) {
    return ChapterState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
      novelPath: novelPath ?? this.novelPath,
    );
  }
}
