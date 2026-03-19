class OnlineChapterContent {
  final String title;
  final int chapter;
  final String content;

  const OnlineChapterContent({
    required this.title,
    required this.chapter,
    required this.content,
  });

  OnlineChapterContent copyWith({
    String? title,
    int? chapter,
    String? content,
  }) {
    return OnlineChapterContent(
      title: title ?? this.title,
      chapter: chapter ?? this.chapter,
      content: content ?? this.content,
    );
  }
}
