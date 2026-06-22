// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:novel_v3/core/models/novel.dart';

class NovelState {
  final List<Novel> novelList;
  final bool isLoading;
  final String error;
  const NovelState({
    required this.novelList,
    required this.isLoading,
    required this.error,
  });
  factory NovelState.empty() {
    return NovelState(novelList: [], isLoading: false, error: '');
  }

  NovelState copyWith({
    List<Novel>? novelList,
    bool? isLoading,
    String? error,
  }) {
    return NovelState(
      novelList: novelList ?? this.novelList,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
