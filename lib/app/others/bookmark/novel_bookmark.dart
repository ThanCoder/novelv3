class NovelBookmark {
  final String title;
  NovelBookmark({required this.title});

  static String get getDBName => 'novel_bookmark.db.json';

  NovelBookmark copyWith({String? title}) {
    return NovelBookmark(title: title ?? this.title);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'title': title};
  }

  factory NovelBookmark.fromMap(Map<String, dynamic> map) {
    return NovelBookmark(title: map['title'] as String);
  }
}
