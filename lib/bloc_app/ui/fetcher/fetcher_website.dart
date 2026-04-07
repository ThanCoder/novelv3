import 'package:novel_v3/bloc_app/ui/fetcher/query_result_list.dart';
import 'package:t_html_parser/core/q_result/attributes.dart';
import 'package:t_html_parser/core/q_result/query_result.dart';
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
  final FetcherQuery tags;

  const DetailPageQuery({
    required this.title,
    required this.coverUrl,
    required this.otherTitles,
    required this.author,
    required this.translator,
    required this.description,
    required this.tags,
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

enum FetcherQueryType {
  single,
  list;

  static FetcherQueryType fromName(String name) {
    if (name == list.name) {
      return list;
    }
    return single;
  }
}

class FetcherQuery {
  final int index;
  final String attribue;
  final String selector;
  final FetcherQueryType type;

  const FetcherQuery({
    required this.attribue,
    required this.selector,
    this.index = 0,
    this.type = FetcherQueryType.single,
  });

  List<String> getResult(String html) {
    List<String> results = [];
    if (type == FetcherQueryType.single) {
      final res = QueryResult(
        index: index,
        attr: Attribute(attribue),
        selector: selector,
      ).getResult(html);
      if (res != null && res.isNotEmpty) {
        results.add(res);
      }
    }
    // list
    if (type == FetcherQueryType.list) {
      final res = QueryResultList(
        attr: Attribute(attribue),
        selector: selector,
      ).getResult(html);
      if (res.isNotEmpty) {
        results.addAll(res);
      }
    }
    return results;
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'attribue': attribue,
      'selector': selector,
      'type': type.name,
    };
  }

  factory FetcherQuery.fromJson(Map<String, dynamic> json) {
    return FetcherQuery(
      index: json.getInt(['index']),
      attribue: json.getString(['attribue']),
      selector: json.getString(['selector']),
      type: FetcherQueryType.fromName(json.getString(['type'])),
    );
  }
}
