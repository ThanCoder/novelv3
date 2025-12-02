class FetcherResponse {
  final String url;
  final String title;
  final int chapterNumber;
  final String content;
  FetcherResponse({
    required this.url,
    required this.title,
    required this.chapterNumber,
    required this.content,
  });

  FetcherResponse copyWith({
    String? url,
    String? title,
    int? chapterNumber,
    String? content,
  }) {
    return FetcherResponse(
      url: url ?? this.url,
      title: title ?? this.title,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      content: content ?? this.content,
    );
  }
}
