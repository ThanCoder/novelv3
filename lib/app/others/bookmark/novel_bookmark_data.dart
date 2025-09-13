// ignore_for_file: public_member_api_docs, sort_constructors_first
class NovelBookmarkData {
  String title;
  NovelBookmarkData({required this.title});

  factory NovelBookmarkData.fromMap(Map<String, dynamic> map) {
    return NovelBookmarkData(title: map['title'] as String);
  }
  Map<String, dynamic> toMap() => {'title': title};
}
