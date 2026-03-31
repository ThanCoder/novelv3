class ChapterContentResult {
  final String title;
  final String content;

  const ChapterContentResult({required this.title, required this.content});
}

class ChapterOnlineContentResult {
  final int number;
  final String title;
  final String content;

  const ChapterOnlineContentResult({
    required this.number,
    required this.title,
    required this.content,
  });
}

class FetcherNovelResult {
  final List<NovelItemResult> list;
  final String nextUrl;

  const FetcherNovelResult({required this.list, required this.nextUrl});

  FetcherNovelResult copyWith({List<NovelItemResult>? list, String? nextUrl}) {
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

class NovelDetailResult {
  final String otherTitles;
  final String author;
  final String translator;
  final String description;

  const NovelDetailResult({
    required this.otherTitles,
    required this.author,
    required this.translator,
    required this.description,
  });
}

class MultiChapterResult {
  final int chNumber;
  final String title;
  final String url;

  const MultiChapterResult({
    required this.chNumber,
    required this.title,
    required this.url,
  });

  MultiChapterResult copyWith({int? chNumber, String? title, String? url}) {
    return MultiChapterResult(
      chNumber: chNumber ?? this.chNumber,
      title: title ?? this.title,
      url: url ?? this.url,
    );
  }
}
