import 'package:novel_v3/app/models/chapter_model.dart';

class ChapterBookMarkModel {
  String title;
  String chapter;
  ChapterBookMarkModel({
    required this.title,
    required this.chapter,
  });

  factory ChapterBookMarkModel.fromChapter(ChapterModel chapter) {
    return ChapterBookMarkModel(title: 'Untitled', chapter: chapter.title);
  }

  factory ChapterBookMarkModel.fromJson(Map<String, dynamic> map) {
    String title = map['title'] ?? 'Untitled';
    title = title.isEmpty ? 'Untitled' : title;
    return ChapterBookMarkModel(
      title: title,
      chapter: map['chapter'] ?? '',
    );
  }
  Map<String, dynamic> toMap() => {
        'title': title,
        'chapter': chapter,
      };

  static toMapList(List<ChapterBookMarkModel> bml) =>
      bml.map((bm) => bm.toMap()).toList();

  @override
  String toString() {
    return '\ntilte => $title\nchapter => $chapter';
  }
}
