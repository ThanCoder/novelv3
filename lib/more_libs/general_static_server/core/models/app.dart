import 'package:than_pkg/services/t_map.dart';

class App {
  final String id;
  final String title;
  final String packageName;
  final String coverSource;
  final String githubUrl;
  final String desc;
  final String changeLogUrl;
  final String readmeUrl;
  final String licenseUrl;
  final DateTime date;
  App({
    required this.id,
    required this.title,
    required this.packageName,
    required this.coverSource,
    required this.githubUrl,
    required this.desc,
    required this.changeLogUrl,
    required this.readmeUrl,
    required this.licenseUrl,
    required this.date,
  });

  App copyWith({
    String? id,
    String? title,
    String? packageName,
    String? coverSource,
    String? githubUrl,
    String? desc,
    String? changeLogUrl,
    String? readmeUrl,
    String? licenseUrl,
    DateTime? date,
  }) {
    return App(
      id: id ?? this.id,
      title: title ?? this.title,
      packageName: packageName ?? this.packageName,
      coverSource: coverSource ?? this.coverSource,
      githubUrl: githubUrl ?? this.githubUrl,
      desc: desc ?? this.desc,
      changeLogUrl: changeLogUrl ?? this.changeLogUrl,
      readmeUrl: readmeUrl ?? this.readmeUrl,
      licenseUrl: licenseUrl ?? this.licenseUrl,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'packageName': packageName,
      'coverSource': coverSource,
      'githubUrl': githubUrl,
      'desc': desc,
      'changeLogUrl': changeLogUrl,
      'readmeUrl': readmeUrl,
      'licenseUrl': licenseUrl,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory App.fromMap(Map<String, dynamic> map) {
    return App(
      id: map.getString(['id']),
      title: map.getString(['title']),
      packageName: map.getString(['packageName']),
      coverSource: map.getString(['coverSource']),
      githubUrl: map.getString(['githubUrl']),
      desc: map.getString(['desc']),
      changeLogUrl: map.getString(['changeLogUrl']),
      readmeUrl: map.getString(['readmeUrl']),
      licenseUrl: map.getString(['licenseUrl']),
      date: DateTime.fromMillisecondsSinceEpoch(map.getInt(['date'])),
    );
  }
}
