class NovelBookmark {
  final String id;
  final String title;

  const NovelBookmark({required this.id, required this.title});

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }

  factory NovelBookmark.fromJson(Map<String, dynamic> json) {
    return NovelBookmark(id: json['id'], title: json['title']);
  }
}
