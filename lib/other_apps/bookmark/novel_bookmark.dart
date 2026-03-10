import 'package:dart_core_extensions/dart_core_extensions.dart';

class NovelBookmark {
  final String id;
  final String title;
  NovelBookmark({required this.id, required this.title});

  static String get getDBName => 'novel_bookmark.db.json';

  NovelBookmark copyWith({String? id, String? title}) {
    return NovelBookmark(id: id ?? this.id, title: title ?? this.title);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }

  factory NovelBookmark.fromJson(Map<String, dynamic> json) {
    return NovelBookmark(
      id: json.getString(['id'], def: '-1'),
      title: json.getString(['title']),
    );
  }
}
