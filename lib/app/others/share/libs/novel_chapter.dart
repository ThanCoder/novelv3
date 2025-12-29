class NovelChapter {
  final int id;
  final String novelId;
  final int chapter;
  NovelChapter({
    required this.id,
    required this.novelId,
    required this.chapter,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'novelId': novelId, 'chapter': chapter};
  }

  factory NovelChapter.fromMap(Map<String, dynamic> map) {
    return NovelChapter(
      id: map['id'] as int,
      novelId: map['novelId'] as String,
      chapter: map['chapter'] as int,
    );
  }
}
