class ChapterContent {
  final int autoId;
  final int chapterId;
  final String content;
  ChapterContent({
    this.autoId = 0,
    required this.chapterId,
    required this.content,
  });

  ChapterContent copyWith({int? autoId, int? chapterId, String? content}) {
    return ChapterContent(
      autoId: autoId ?? this.autoId,
      chapterId: chapterId ?? this.chapterId,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'autoId': autoId,
      'chapterId': chapterId,
      'content': content,
    };
  }

  factory ChapterContent.fromMap(Map<String, dynamic> map) {
    return ChapterContent(
      autoId: map['autoId'] as int,
      chapterId: map['chapterId'] as int,
      content: map['content'] as String,
    );
  }
}
