// ignore_for_file: public_member_api_docs, sort_constructors_first
class ReleaseAppModel {
  String id;
  String version;
  String platform;
  String url;
  String description;
  String releaseId;
  String date;
  ReleaseAppModel({
    required this.id,
    required this.version,
    required this.platform,
    required this.url,
    required this.description,
    required this.releaseId,
    required this.date,
  });

  factory ReleaseAppModel.fromMap(Map<String, dynamic> map) {
    return ReleaseAppModel(
      id: map['id'],
      version: map['version'],
      platform: map['platform'],
      url: map['url'],
      description: map['description'],
      releaseId: map['releaseId'],
      date: map['date'],
    );
  }

  @override
  String toString() {
    return version;
  }
}
