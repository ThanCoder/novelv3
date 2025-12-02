import 'package:t_db/t_db.dart';

class ChapterAdapter extends TDAdapter<Chapter> {
  @override
  Chapter fromMap(Map<String, dynamic> map) {
    return Chapter.fromMap(map);
  }

  @override
  int getId(Chapter value) {
    return value.autoId;
  }

  @override
  int getUniqueFieldId() {
    return 1;
  }

  @override
  Map<String, dynamic> toMap(Chapter value) {
    return value.toMap();
  }
}

class Chapter {
  final int autoId;
  final int number;
  final String title;
  final DateTime date;
  String? novelPath;
  String? content;
  Chapter({
    this.autoId = 0,
    required this.number,
    required this.title,
    required this.date,
    this.novelPath,
    this.content,
  });
  factory Chapter.create({
    required int number,
    String title = 'Untitled',
    String? content,
  }) {
    return Chapter(
      number: number,
      title: title,
      date: DateTime.now(),
      content: content,
    );
  }

  Chapter copyWith({
    int? autoId,
    int? number,
    String? title,
    DateTime? date,
    String? novelPath,
    String? content,
  }) {
    return Chapter(
      autoId: autoId ?? this.autoId,
      number: number ?? this.number,
      title: title ?? this.title,
      date: date ?? this.date,
      novelPath: novelPath ?? this.novelPath,
      content: content ?? this.content,
    );
  }

  static bool isChapterFile(String title) => int.tryParse(title) != null;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'autoId': autoId,
      'number': number,
      'title': title,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      autoId: map['autoId'] as int,
      number: map['number'] as int,
      title: map['title'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }
}
