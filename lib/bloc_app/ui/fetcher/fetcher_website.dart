import 'package:novel_v3/bloc_app/ui/fetcher/query_result_list.dart';
import 'package:t_html_parser/core/q_result/attributes.dart';
import 'package:t_html_parser/core/q_result/query_result.dart';
import 'package:t_html_parser/t_html_parser.dart';
import 'package:than_pkg/than_pkg.dart';

enum FetchType { request, webview }

class FetcherWebsite {
  final String url;
  final String hostUrl;
  final String title;
  final FetchType type;
  final NovelListPageQuery novelListPageQuery;
  final ChapterPageQuery? chapterPageQuery;
  final DetailPageQuery? detailPageQuery;
  final ChapterListPageQuery? chapterListPageQuery;

  const FetcherWebsite({
    required this.hostUrl,
    required this.url,
    required this.title,
    this.type = FetchType.request,
    required this.novelListPageQuery,
    this.chapterPageQuery,
    this.detailPageQuery,
    this.chapterListPageQuery,
  });
}

class ChapterListPageQuery {
  final String querySelectorAll;
  final FetcherQuery pageUrlQuery;
  final FetcherQuery titleQuery;
  final FetcherQuery numberQuery;
  final NextUrlQuery? nextUrlQuery;

  const ChapterListPageQuery({
    required this.querySelectorAll,
    required this.pageUrlQuery,
    required this.titleQuery,
    required this.numberQuery,
    this.nextUrlQuery,
  });
}

class NovelListPageQuery {
  final String querySelectorAll;
  final FetcherQuery pageUrlQuery;
  final FetcherQuery titleQuery;
  final FetcherQuery coverUrlQuery;
  final NextUrlQuery nextUrlQuery;

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
      nextUrlQuery: NextUrlQuery.empty(),
    );
  }
}

class NextUrlQuery {
  final String querySelectorAll;
  final String? hostUrl;
  final FetcherQuery itemUrlQuery;
  final FetcherQuery itemTextQuery;

  factory NextUrlQuery.empty() {
    return NextUrlQuery(
      querySelectorAll: '',
      itemUrlQuery: FetcherQuery(attribue: '', selector: ''),
      itemTextQuery: FetcherQuery(attribue: '', selector: ''),
    );
  }

  const NextUrlQuery({
    required this.querySelectorAll,
    this.hostUrl,
    required this.itemUrlQuery,
    required this.itemTextQuery,
  });
}

class DetailPageQuery {
  final FetcherQuery author;
  final FetcherQuery? otherTitles;
  final FetcherQuery? translator;
  final FetcherQuery description;
  final FetcherQuery title;
  final FetcherQuery coverUrl;
  final FetcherQuery tags;

  const DetailPageQuery({
    required this.title,
    required this.coverUrl,
    required this.author,
    this.otherTitles,
    this.translator,
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

  String getFromElement(Element ele) {
    if (attribue == 'text') {
      if (selector.isEmpty) {
        return ele.text.trim();
      }
      return ele.getQuerySelectorText(selector: selector).trim();
    }
    if (attribue == 'html') {
      if (selector.isEmpty) {
        return ele.innerHtml.cleanHtmlTag();
      }
      return ele.getQuerySelectorHtml(selector: selector).cleanHtmlTag();
    }
    if (selector.isEmpty) {
      return (ele.attributes[attribue] ?? '').trim();
    }
    return ele.getQuerySelectorAttr(selector: selector, attr: attribue).trim();
  }

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
