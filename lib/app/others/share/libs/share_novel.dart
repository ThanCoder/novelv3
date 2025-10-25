class ShareNovel {
  String title;
  String path;
  bool isAdult;
  bool isCompleted;
  DateTime date;
  ShareNovel({
    required this.title,
    required this.path,
    required this.isAdult,
    required this.isCompleted,
    required this.date,
  });

  String getCoverPath(String hostUrl) =>
      '$hostUrl/download?path=$path/cover.png';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'path': path,
      'isAdult': isAdult,
      'isCompleted': isCompleted,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory ShareNovel.fromMap(Map<String, dynamic> map) {
    return ShareNovel(
      title: map['title'] as String,
      path: map['path'] as String,
      isAdult: map['isAdult'] as bool,
      isCompleted: map['isCompleted'] as bool,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }
}
