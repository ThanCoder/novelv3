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
  final List<FetcherNovelNextUrl> nextUrls;

  const FetcherNovelResult({required this.list, required this.nextUrls});

  FetcherNovelResult copyWith({
    List<NovelItemResult>? list,
    List<FetcherNovelNextUrl>? nextUrls,
  }) {
    return FetcherNovelResult(
      list: list ?? this.list,
      nextUrls: nextUrls ?? this.nextUrls,
    );
  }
}

class FetcherNovelNextUrl {
  final String title;
  final String url;

  const FetcherNovelNextUrl({required this.title, required this.url});
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
