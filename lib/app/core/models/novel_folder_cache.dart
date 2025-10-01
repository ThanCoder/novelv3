import 'package:novel_v3/app/novel_dir_app.dart';

class NovelFolderCache {
  final int dateInt;
  final List<Novel> list;
  NovelFolderCache({required this.dateInt, required this.list});

  NovelFolderCache copyWith({int? dateInt, List<Novel>? list}) {
    return NovelFolderCache(
      dateInt: dateInt ?? this.dateInt,
      list: list ?? this.list,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'dateInt': dateInt,
      'list': list.map((x) => x.toMap()).toList(),
    };
  }

  factory NovelFolderCache.fromMap(Map<String, dynamic> map) {
    List<dynamic> list = map['list'] ?? [];
    return NovelFolderCache(
      dateInt: map['dateInt'] as int,
      list: list.map((e) => Novel.fromMap(e)).toList(),
    );
  }
}
