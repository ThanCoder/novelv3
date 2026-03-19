import 'package:than_pkg/than_pkg.dart';

class FetcherWebsite {
  final String url;
  final String title;
  final FetcherWebsiteQuery titleQuery;
  final FetcherWebsiteQuery contentQuery;

  const FetcherWebsite({
    required this.url,
    required this.title,
    required this.titleQuery,
    required this.contentQuery,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'titleQuery': titleQuery.toJson(),
      'contentQuery': contentQuery.toJson(),
    };
  }

  factory FetcherWebsite.fromJson(Map<String, dynamic> json) {
    return FetcherWebsite(
      url: json['url'],
      title: json['title'],
      titleQuery: FetcherWebsiteQuery.fromJson(json['titleQuery']),
      contentQuery: FetcherWebsiteQuery.fromJson(json['contentQuery']),
    );
  }
}

class FetcherWebsiteQuery {
  final int index;
  final String attribue;
  final String selector;

  const FetcherWebsiteQuery({
    required this.index,
    required this.attribue,
    required this.selector,
  });

  Map<String, dynamic> toJson() {
    return {'index': index, 'attribue': attribue, 'selector': selector};
  }

  factory FetcherWebsiteQuery.fromJson(Map<String, dynamic> json) {
    return FetcherWebsiteQuery(
      index: json.getInt(['index']),
      attribue: json.getString(['attribue']),
      selector: json.getString(['selector']),
    );
  }
}
