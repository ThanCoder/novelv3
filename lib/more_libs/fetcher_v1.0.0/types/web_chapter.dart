// ignore_for_file: public_member_api_docs, sort_constructors_first
class WebChapter {
  final String title;
  final String url;
  final int index;
  WebChapter({required this.title, required this.url, required this.index});

  @override
  String toString() {
    return 'number: $index - title: $title; ';
  }

  WebChapter copyWith({String? title, String? url, int? index}) {
    return WebChapter(
      title: title ?? this.title,
      url: url ?? this.url,
      index: index ?? this.index,
    );
  }
}
