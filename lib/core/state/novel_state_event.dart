import 'package:novel_v3/core/models/novel.dart';

sealed class NovelStateEvent {}

class NovelSourceLoading extends NovelStateEvent {}

class NovelSourceError extends NovelStateEvent {
  final String error;
  NovelSourceError(this.error);
}

class NovelSourceLoaded extends NovelStateEvent {
  final List<Novel> list;
  NovelSourceLoaded(this.list);
}
