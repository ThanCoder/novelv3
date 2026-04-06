import 'package:than_pkg/than_pkg.dart';

class FetcherWebsite {
  final String url;
  final String title;
  final NovelListPageQuery novelListPageQuery;
  final ChapterPageQuery? chapterPageQuery;
  final DetailPageQuery? detailPageQuery;

  const FetcherWebsite({
    required this.url,
    required this.title,
    required this.novelListPageQuery,
    this.chapterPageQuery,
    this.detailPageQuery,
  });
}

class NovelListPageQuery {
  final String querySelectorAll;
  final FetcherQuery pageUrlQuery;
  final FetcherQuery titleQuery;
  final FetcherQuery coverUrlQuery;
  final FetcherQuery nextUrlQuery;

  const NovelListPageQuery({
    required this.querySelectorAll,
    required this.titleQuery,
    required this.pageUrlQuery,
    required this.coverUrlQuery,
    required this.nextUrlQuery,
  });

  factory NovelListPageQuery.createEmpty() {
    return NovelListPageQuery(
      querySelectorAll: '',
      titleQuery: FetcherQuery(index: 0, attribue: '', selector: ''),
      pageUrlQuery: FetcherQuery(index: 0, attribue: '', selector: ''),
      coverUrlQuery: FetcherQuery(index: 0, attribue: '', selector: ''),
      nextUrlQuery: FetcherQuery(index: 0, attribue: '', selector: ''),
    );
  }
}

class DetailPageQuery {
  final FetcherQuery otherTitles;
  final FetcherQuery author;
  final FetcherQuery translator;
  final FetcherQuery description;
  final FetcherQuery title;
  final FetcherQuery coverUrl;

  const DetailPageQuery({
    required this.title,
    required this.coverUrl,
    required this.otherTitles,
    required this.author,
    required this.translator,
    required this.description,
  });
}

class ChapterPageQuery {
  final FetcherQuery titleQuery;
  final FetcherQuery contentQuery;

  const ChapterPageQuery({
    required this.titleQuery,
    required this.contentQuery,
  });

  Map<String, dynamic> toJson() {
    return {
      'titleQuery': titleQuery.toJson(),
      'contentQuery': contentQuery.toJson(),
    };
  }

  factory ChapterPageQuery.fromJson(Map<String, dynamic> json) {
    return ChapterPageQuery(
      titleQuery:
          json['titleQuery'] ?? FetcherQuery.fromJson(json['titleQuery']),
      contentQuery:
          json['contentQuery'] ?? FetcherQuery.fromJson(json['contentQuery']),
    );
  }
}

class FetcherQuery {
  final int index;
  final String attribue;
  final String selector;

  const FetcherQuery({
    required this.index,
    required this.attribue,
    required this.selector,
  });

  Map<String, dynamic> toJson() {
    return {'index': index, 'attribue': attribue, 'selector': selector};
  }

  factory FetcherQuery.fromJson(Map<String, dynamic> json) {
    return FetcherQuery(
      index: json.getInt(['index']),
      attribue: json.getString(['attribue']),
      selector: json.getString(['selector']),
    );
  }
}
