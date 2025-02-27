// ignore_for_file: public_member_api_docs, sort_constructors_first
class OnlineNovelModel {
  static final dbName = 'novel';
  int? id;
  String title;
  String author;
  String user;
  String desc;
  String coverUrl;
  String genres;
  bool isAdult;
  bool isCompleted;
  bool isPublish;
  DateTime? createdAt;
  OnlineNovelModel({
    this.title = 'Untitled',
    this.author = 'Unknown',
    this.user = 'ThanCoder',
    this.desc = '',
    this.coverUrl = '',
    this.genres = '',
    this.isAdult = false,
    this.isCompleted = false,
    this.isPublish = false,
  });

  factory OnlineNovelModel.fromMap(Map<String, dynamic> map) {
    final novel = OnlineNovelModel(
      title: map['title'],
      user: map['user'],
      author: map['author'],
      genres: map['genres'],
      desc: map['desc'],
      coverUrl: map['cover_url'],
      isAdult: map['is_adult'],
      isCompleted: map['is_completed'],
      isPublish: map['is_publish'],
    );
    novel.id = map['id'];
    novel.createdAt = DateTime.parse(map['created_at']);
    return novel;
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'author': author,
        'user': user,
        'desc': desc,
        'cover_url': coverUrl,
        'genres': genres,
        'is_adult': isAdult,
        'is_completed': isCompleted,
        'is_publish': isPublish,
      };

  @override
  String toString() {
    return '\ntitle => $title\n';
  }
}
