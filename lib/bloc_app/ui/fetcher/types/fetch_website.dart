import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_website.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'hostUrl': hostUrl,
      'title': title,
      'type': type.name,
      'novelListPageQuery': novelListPageQuery.toJson(),
      'chapterPageQuery': chapterPageQuery?.toJson(),
      'detailPageQuery': detailPageQuery?.toJson(),
      'chapterListPageQuery': chapterListPageQuery?.toJson(),
    };
  }

  factory FetcherWebsite.fromJson(Map<String, dynamic> json) {
    return FetcherWebsite(
      url: json['url'],
      hostUrl: json['hostUrl'],
      title: json['title'],
      type: FetchType.values.firstWhere((e) => e.name == json['type']),
      novelListPageQuery: NovelListPageQuery.fromJson(
        json['novelListPageQuery'],
      ),
      chapterPageQuery: json['chapterPageQuery'] == null
          ? null
          : ChapterPageQuery.fromJson(json['chapterPageQuery']),
      detailPageQuery: json['detailPageQuery'] == null
          ? null
          : DetailPageQuery.fromJson(json['detailPageQuery']),
      chapterListPageQuery: json['chapterListPageQuery'] == null
          ? null
          : ChapterListPageQuery.fromJson(json['chapterListPageQuery']),
    );
  }
}
