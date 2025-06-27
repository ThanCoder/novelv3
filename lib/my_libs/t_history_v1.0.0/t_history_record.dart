import 't_methods.dart';

class THistoryRecord {
  String title;
  String desc;
  TMethods method;
  DateTime date;
  THistoryRecord({
    required this.title,
    required this.desc,
    required this.method,
    required this.date,
  });
  factory THistoryRecord.create({
    String title = 'Untitled',
    String desc = '',
    TMethods method = TMethods.add,
  }) {
    return THistoryRecord(
      title: title,
      desc: desc,
      method: method,
      date: DateTime.now(),
    );
  }

  factory THistoryRecord.fromMap(Map<String, dynamic> map) {
    final title = map['title'];
    final desc = map['desc'];
    final method = TMethods.getType(map['method']);
    final date = DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0);

    return THistoryRecord(
      title: title,
      desc: desc,
      method: method,
      date: date,
    );
  }
  Map<String, dynamic> get toMap => {
        'title': title,
        'desc': desc,
        'method': method.name,
        'date': date.millisecondsSinceEpoch,
      };
}
