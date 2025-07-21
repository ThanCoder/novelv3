import 'package:novel_v3/app/models/chapter_model.dart';

class ChapterBookmarkModel {
  String title;
  int chapter;
  ChapterBookmarkModel({
    required this.title,
    required this.chapter,
  });

  factory ChapterBookmarkModel.fromMap(Map<String, dynamic> map) {
    int chapter = 1;
    String title = '';
    final ch = map['chapter'] ?? 1;
    if (ch is String) {
      if (int.tryParse(ch) != null) {
        chapter = int.parse(ch);
      }
    }
    if (ch is int) {
      chapter = ch;
    }

    title = map['title'] ?? 'Untitled';
    if (title.isEmpty) {
      title = 'Untitled';
    }
    return ChapterBookmarkModel(
      title: title,
      chapter: chapter,
    );
  }

  ChapterModel toChapter(String novelPath) {
    return ChapterModel(
      title: title,
      number: chapter,
      path: '$novelPath/$chapter',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'chapter': chapter,
      };

  @override
  String toString() {
    return '$chapter';
  }
}
