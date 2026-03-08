class NovelFile {
  final String name;
  final String mime;
  final int size;
  final DateTime date;
  NovelFile({
    required this.name,
    required this.mime,
    required this.size,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'mime': mime,
      'size': size,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory NovelFile.fromMap(Map<String, dynamic> map) {
    return NovelFile(
      name: map['name'] as String,
      mime: map['mime'] as String,
      size: map['size'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }
}
