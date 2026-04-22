import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_website.dart';
import 'package:than_pkg/services/index.dart';

class ChapterListPageQuery {
  final String querySelectorAll;
  final String autoAddUrlParam;
  final FetcherQuery pageUrlQuery;
  final FetcherQuery titleQuery;
  final FetcherQuery numberQuery;
  final NextUrlQuery? nextUrlQuery;

  const ChapterListPageQuery({
    required this.querySelectorAll,
    this.autoAddUrlParam = '',
    required this.pageUrlQuery,
    required this.titleQuery,
    required this.numberQuery,
    this.nextUrlQuery,
  });

  Map<String, dynamic> toJson() {
    return {
      'querySelectorAll': querySelectorAll,
      'autoAddUrlParam': autoAddUrlParam,
      'pageUrlQuery': pageUrlQuery.toJson(),
      'titleQuery': titleQuery.toJson(),
      'numberQuery': numberQuery.toJson(),
      'nextUrlQuery': nextUrlQuery?.toJson(),
    };
  }

  factory ChapterListPageQuery.fromJson(Map<String, dynamic> json) {
    return ChapterListPageQuery(
      querySelectorAll: json['querySelectorAll'],
      autoAddUrlParam: json.getString(['autoAddUrlParam']),
      pageUrlQuery: FetcherQuery.fromJson(json['pageUrlQuery']),
      titleQuery: FetcherQuery.fromJson(json['titleQuery']),
      numberQuery: FetcherQuery.fromJson(json['numberQuery']),
      nextUrlQuery: json['nextUrlQuery'] == null
          ? null
          : NextUrlQuery.fromJson(json['nextUrlQuery']),
    );
  }
}
