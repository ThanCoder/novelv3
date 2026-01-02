import 'package:than_pkg/than_pkg.dart';

class ChapterBookmark {
  final String title;
  final int chapter;
  ChapterBookmark({required this.title, required this.chapter});

  ChapterBookmark copyWith({String? title, int? chapter}) {
    return ChapterBookmark(
      title: title ?? this.title,
      chapter: chapter ?? this.chapter,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'title': title, 'chapter': chapter};
  }

  factory ChapterBookmark.fromMap(Map<String, dynamic> map) {
    return ChapterBookmark(
      title: map.getString(['title']),
      chapter: map.getInt(['chapter']),
    );
  }
}
