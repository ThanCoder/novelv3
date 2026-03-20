class FetcherWebsiteResult {
  final String title;
  final String content;

  const FetcherWebsiteResult({required this.title, required this.content});
}

class FetcherNovelResult {
  final List<NovelItemResult> list;
  final String nextUrl;

  const FetcherNovelResult({required this.list, required this.nextUrl});

  FetcherNovelResult copyWith({
    List<NovelItemResult>? list,
    String? nextUrl,
  }) {
    return FetcherNovelResult(
      list: list ?? this.list,
      nextUrl: nextUrl ?? this.nextUrl,
    );
  }
}

class NovelItemResult {
  final String title;
  final String pageUrl;
  final String coverUrl;

  const NovelItemResult({
    required this.title,
    required this.pageUrl,
    required this.coverUrl,
  });
}
