// ignore_for_file: public_member_api_docs, sort_constructors_first
class NovelBookmarkModel {
  String title;
  String path;
  NovelBookmarkModel({
    required this.title,
    required this.path,
  });

  factory NovelBookmarkModel.fromMap(Map<String, dynamic> map) {
    return NovelBookmarkModel(
      title: map['title'] ?? '',
      path: map['path'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'path': path,
      };

  @override
  String toString() {
    return '\ntitle => $title\npath => $path\n';
  }
}
