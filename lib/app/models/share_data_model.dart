// ignore_for_file: public_member_api_docs, sort_constructors_first
class ShareDataModel {
  String name;
  String path;
  int size;
  int date;
  bool isExists;
  ShareDataModel({
    required this.name,
    required this.path,
    required this.size,
    required this.date,
    this.isExists = false,
  });

  factory ShareDataModel.fromMap(Map<String, dynamic> map) {
    final data = ShareDataModel(
      name: map['name'] ?? '',
      path: map['path'] ?? '',
      size: map['size'] ?? 0,
      date: map['date'] ?? DateTime.now().millisecondsSinceEpoch,
    );
    //check exists

    return data;
  }
}
