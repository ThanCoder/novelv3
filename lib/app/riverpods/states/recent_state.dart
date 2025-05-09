// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:novel_v3/app/models/novel_model.dart';

class RecentState {
  bool isLoading;
  List<NovelModel> list;
  RecentState({
    required this.isLoading,
    required this.list,
  });

  factory RecentState.init() => RecentState(isLoading: false, list: []);

  RecentState copyWith({
    bool? isLoading,
    List<NovelModel>? list,
  }) {
    return RecentState(
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
    );
  }
}
