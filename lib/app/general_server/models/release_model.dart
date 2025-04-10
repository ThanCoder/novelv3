// ignore_for_file: public_member_api_docs, sort_constructors_first
class ReleaseModel {
  String id;
  String title;
  String repository;
  String coverUrl;
  String packageName;
  String description;
  String date;
  ReleaseModel({
    required this.id,
    required this.title,
    required this.repository,
    required this.coverUrl,
    required this.packageName,
    required this.description,
    required this.date,
  });

  factory ReleaseModel.fromMap(Map<String, dynamic> map) {
    return ReleaseModel(
      id: map['id'],
      title: map['title'],
      repository: map['repository'],
      coverUrl: map['coverUrl'],
      packageName: map['packageName'],
      description: map['description'],
      date: map['date'],
    );
  }

  @override
  String toString() {
    return title;
  }
}
