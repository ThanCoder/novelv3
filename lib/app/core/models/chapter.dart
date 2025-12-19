import 'package:novel_v3/app/core/models/chapter_content.dart';
import 'package:t_db/t_db.dart';
import 'package:than_pkg/than_pkg.dart';

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

  @override
  List<HBRelation> relations() {
    return [
      HBRelation(
        targetType: ChapterContent,
        foreignKey: 'chapterId',
        onDelete: RelationAction.cascade,
      ),
    ];
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
    String? novelPath,
  }) {
    return Chapter(
      number: number,
      title: title,
      date: DateTime.now(),
      content: content,
      novelPath: novelPath,
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
      number: map.getInt(['number'], def: -1),
      title: map.getString(['title'], def: 'Null'),
      date: DateTime.fromMillisecondsSinceEpoch(map.getInt(['date'])),
    );
  }
}
