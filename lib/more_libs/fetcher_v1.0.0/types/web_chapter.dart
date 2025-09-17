class WebChapter {
  final String title;
  final String url;
  final int index;
  WebChapter({required this.title, required this.url, required this.index});

  @override
  String toString() {
    return 'title: $title';
  }
}
