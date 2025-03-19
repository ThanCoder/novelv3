// ignore_for_file: public_member_api_docs, sort_constructors_first
class GenresModel {
  String id;
  String title;
  int date;
  bool isSelected;
  GenresModel({
    required this.id,
    required this.title,
    required this.date,
    this.isSelected = false,
  });

  factory GenresModel.fromMap(Map<String, dynamic> map) {
    return GenresModel(
      id: map['id'],
      title: map['title'],
      date: map['date'],
    );
  }
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'date': date,
      };

  @override
  String toString() {
    return '\nid => $id\ntitle => $title\ndate => $date\n';
  }
}
