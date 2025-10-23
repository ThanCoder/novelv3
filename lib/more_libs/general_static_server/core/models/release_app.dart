import 'package:than_pkg/than_pkg.dart';

enum ReleaseTypes {
  android,
  linux;

  static ReleaseTypes getName(String name) {
    if (name == android.name) {
      return android;
    }
    if (name == linux.name) {
      return linux;
    }
    return android;
  }
}

class ReleaseApp {
  final String id;
  final String appId;
  final String title;
  final String coverSource;
  final String desc;
  final String size;
  final DateTime date;
  final bool isDirectLink;
  final String version;
  final ReleaseTypes type;
  ReleaseApp({
    required this.id,
    required this.appId,
    required this.title,
    required this.coverSource,
    required this.desc,
    required this.size,
    required this.date,
    required this.isDirectLink,
    required this.version,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'appId': appId,
      'title': title,
      'coverSource': coverSource,
      'desc': desc,
      'size': size,
      'isDirectLink': isDirectLink,
      'version': version,
      'type': type.name,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory ReleaseApp.fromMap(Map<String, dynamic> map) {
    final typeStr = map.getString(['type']);
    return ReleaseApp(
      id: map.getString(['id']),
      appId: map.getString(['appId']),
      title: map.getString(['title']),
      coverSource: map.getString(['coverSource']),
      desc: map.getString(['desc']),
      size: map.getString(['size']),
      version: map.getString(['version']),
      isDirectLink: map.getBool(['isDirectLink']),
      type: ReleaseTypes.getName(typeStr),
      date: DateTime.fromMillisecondsSinceEpoch(map.getInt(['date'])),
    );
  }

  ReleaseApp copyWith({
    String? id,
    String? appId,
    String? title,
    String? coverSource,
    String? desc,
    String? size,
    DateTime? date,
    bool? isDirectLink,
    String? version,
    ReleaseTypes? type,
  }) {
    return ReleaseApp(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      title: title ?? this.title,
      coverSource: coverSource ?? this.coverSource,
      desc: desc ?? this.desc,
      size: size ?? this.size,
      date: date ?? this.date,
      isDirectLink: isDirectLink ?? this.isDirectLink,
      version: version ?? this.version,
      type: type ?? this.type,
    );
  }
}
