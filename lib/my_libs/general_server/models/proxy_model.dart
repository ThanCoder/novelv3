// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProxyModel {
  String title;
  String url;
  String type;
  String date;
  ProxyModel({
    required this.title,
    required this.url,
    required this.type,
    required this.date,
  });

  factory ProxyModel.fromMap(Map<String, dynamic> map) {
    return ProxyModel(
      title: map['title'],
      url: map['url'],
      type: map['type'],
      date: map['date'],
    );
  }
}
