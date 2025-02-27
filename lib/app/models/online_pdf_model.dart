// ignore_for_file: public_member_api_docs, sort_constructors_first
class OnlinePdfModel {
  int id;
  int date;
  String title;
  String user;
  String coverUrl;
  String downloadUrls;
  String desc;
  String size;
  OnlinePdfModel({
    required this.id,
    required this.date,
    required this.title,
    required this.user,
    required this.coverUrl,
    required this.downloadUrls,
    required this.desc,
    required this.size,
  });

  factory OnlinePdfModel.fromMap(Map<String, dynamic> map) {
    final date = DateTime.parse(map['created_at']).millisecondsSinceEpoch;
    return OnlinePdfModel(
      id: map['id'],
      date: date,
      title: map['id'],
      user: map['id'],
      coverUrl: map['id'],
      downloadUrls: map['id'],
      desc: map['id'],
      size: map['id'],
    );
  }
  Map<String, dynamic> toMap() => {
        'title': title,
        'user': user,
        'cover_url': coverUrl,
        'download_urls': downloadUrls,
        'desc': desc,
        'size': size,
      };
}
