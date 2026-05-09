import 'package:dart_core_extensions/dart_core_extensions.dart';

class Chapter {
  final int autoId;
  final int number;
  final String title;
  final DateTime date;
  String novelId;
  String? content;

  Chapter({
    this.autoId = 0,
    required this.number,
    required this.title,
    required this.date,
    required this.novelId,
    this.content,
  });
  factory Chapter.create({
    required int number,
    required String novelId,
    String title = 'Untitled',
    String? content,
  }) {
    return Chapter(
      number: number,
      title: title,
      date: DateTime.now(),
      content: content,
      novelId: novelId,
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
      novelId: map.getString(['novelId'], def: '-1'),
      date: DateTime.fromMillisecondsSinceEpoch(map.getInt(['date'])),
    );
  }

  Chapter copyWith({
    int? autoId,
    int? number,
    String? title,
    DateTime? date,
    String? novelId,
    String? content,
  }) {
    return Chapter(
      autoId: autoId ?? this.autoId,
      number: number ?? this.number,
      title: title ?? this.title,
      date: date ?? this.date,
      novelId: novelId ?? this.novelId,
      content: content ?? this.content,
    );
  }

  @override
  String toString() {
    return 'ID: $autoId - Number: $number - T: $title';
  }
}
