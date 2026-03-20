import 'package:than_pkg/than_pkg.dart';

class FetcherWebsite {
  final String url;
  final String title;
  final ChapterPageQuery? chapterPageQuery;

  const FetcherWebsite({
    required this.url,
    required this.title,
    this.chapterPageQuery,
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
