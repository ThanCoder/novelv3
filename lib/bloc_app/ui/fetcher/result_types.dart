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
  final List<String> otherTitles;
  final String author;
  final String translator;
  final String description;
  final String title;
  final String coverUrl;
  final List<String> tags;

  const NovelDetailResult({
    required this.otherTitles,
    required this.author,
    required this.translator,
    required this.description,
    required this.title,
    required this.coverUrl,
    required this.tags,
  });

  NovelDetailResult copyWith({
    List<String>? otherTitles,
    String? author,
    String? translator,
    String? description,
    String? title,
    String? coverUrl,
    List<String>? tags,
  }) {
    return NovelDetailResult(
      otherTitles: otherTitles ?? this.otherTitles,
      author: author ?? this.author,
      translator: translator ?? this.translator,
      description: description ?? this.description,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      tags: tags ?? this.tags,
    );
  }
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
