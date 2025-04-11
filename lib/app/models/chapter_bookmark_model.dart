// ignore_for_file: public_member_api_docs, sort_constructors_first
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
    final ch = map['chapter'] ?? '1';
    if (int.tryParse(ch) != null) {
      chapter = int.parse(ch);
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

  Map<String, dynamic> toMap() => {
        'title': title,
        'chapter': chapter,
      };
}
