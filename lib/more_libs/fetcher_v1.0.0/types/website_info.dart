// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../querys/f_query.dart';

class WebsiteInfo {
  final FQuery? titleQuery;
  final FQuery? coverUrlQuery;
  final FQuery? engTitleQuery;
  final FQuery? authorQuery;
  final FQuery? translatorQuery;
  final FQuery? descriptionQuery;
  final FQuery? tagsQuery;
  WebsiteInfo({
    this.titleQuery,
    this.coverUrlQuery,
    this.engTitleQuery,
    this.authorQuery,
    this.translatorQuery,
    this.descriptionQuery,
    this.tagsQuery,
  });
}

class WebsiteInfoResult {
  final String url;
  final String? title;
  final String? coverUrl;
  final String? engTitle;
  final String? author;
  final String? translator;
  final String? description;
  final String? tags;
  WebsiteInfoResult({
    required this.url,
    this.title,
    this.coverUrl,
    this.engTitle,
    this.author,
    this.translator,
    this.description,
    this.tags,
  });

  WebsiteInfoResult copyWith({
    String? url,
    String? title,
    String? coverUrl,
    String? engTitle,
    String? author,
    String? translator,
    String? description,
    String? tags,
  }) {
    return WebsiteInfoResult(
      url: url ?? this.url,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      engTitle: engTitle ?? this.engTitle,
      author: author ?? this.author,
      translator: translator ?? this.translator,
      description: description ?? this.description,
      tags: tags ?? this.tags,
    );
  }
}
