import 'dart:convert';
import 'dart:io';
import 'package:than_pkg/than_pkg.dart';
import 'package:uuid/uuid.dart';

import '../../services/server_file_services.dart';

class Novel {
  String id;
  String title;
  String author;
  String translator;
  String tags;
  String desc;
  String mc;
  String pageUrls;
  String coverUrl;
  String coverPath;
  DateTime date;
  bool isAdult;
  bool isCompleted;
  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.translator,
    required this.tags,
    required this.desc,
    required this.mc,
    required this.pageUrls,
    required this.coverUrl,
    required this.coverPath,
    required this.date,
    required this.isAdult,
    required this.isCompleted,
  });

  factory Novel.create({
    String title = 'Untitled',
    String author = 'Unknown',
    String translator = 'Unknown',
    String mc = 'Unknown',
    String tags = '',
    String pageUrls = '',
    String desc = '',
    bool isAdult = false,
    bool isCompleted = false,
  }) {
    final id = const Uuid().v4();
    return Novel(
      id: id,
      title: title,
      author: author,
      translator: translator,
      mc: mc,
      tags: tags,
      desc: desc,
      pageUrls: pageUrls,
      coverUrl: '${ServerFileServices.getImageUrl(id)}.png',
      coverPath: '${ServerFileServices.getImagePath()}/$id.png',
      date: DateTime.now(),
      isAdult: isAdult,
      isCompleted: isCompleted,
    );
  }

  factory Novel.fromMapWithUrl(Map<String, dynamic> map) {
    final novel = Novel.fromMap(map);
    novel.coverUrl = ServerFileServices.getImageUrl('${novel.id}.png');
    return novel;
  }
  // config file
  factory Novel.fromV3ConfigFile(String path) {
    final file = File(path);
    final map = jsonDecode(file.readAsStringSync());
    final config = Novel.fromV3Map(map);
    config.coverPath =
        '${file.parent.path}/${path.getName().replaceAll('.config.json', '.png')}';
    return config;
  }

  factory Novel.fromV3Map(Map<String, dynamic> map) {
    final dateFromMillisecondsSinceEpoch = MapServices.get<int>(map, [
      'date',
    ], defaultValue: 0);

    return Novel(
      id: MapServices.get(map, ['id'], defaultValue: const Uuid().v4()),
      title: MapServices.get(map, ['title'], defaultValue: 'Untitled'),
      author: MapServices.get(map, ['author'], defaultValue: 'Unknown'),
      translator: MapServices.get(map, ['translator'], defaultValue: 'Unknown'),
      mc: MapServices.get(map, ['mc'], defaultValue: 'Unknown'),
      tags: MapServices.get(map, ['tags'], defaultValue: ''),
      desc: MapServices.get(map, ['desc'], defaultValue: ''),
      pageUrls: MapServices.get(map, ['pageUrls'], defaultValue: ''),
      coverUrl: MapServices.get(map, ['coverUrl'], defaultValue: ''),
      coverPath: MapServices.get(map, ['coverPath'], defaultValue: ''),
      date: DateTime.fromMillisecondsSinceEpoch(dateFromMillisecondsSinceEpoch),
      isAdult: MapServices.get(map, ['isAdult'], defaultValue: false),
      isCompleted: MapServices.get(map, ['isCompleted'], defaultValue: false),
    );
  }

  // map
  factory Novel.fromMap(Map<String, dynamic> map) {
    final dateFromMillisecondsSinceEpoch = MapServices.get<int>(map, [
      'date',
    ], defaultValue: 0);

    return Novel(
      id: MapServices.get(map, ['id'], defaultValue: ''),
      title: MapServices.get(map, ['title'], defaultValue: 'Untitled'),
      author: MapServices.get(map, ['author'], defaultValue: 'Unknown'),
      translator: MapServices.get(map, ['translator'], defaultValue: 'Unknown'),
      mc: MapServices.get(map, ['mc'], defaultValue: 'Unknown'),
      tags: MapServices.get(map, ['tags'], defaultValue: ''),
      desc: MapServices.get(map, ['desc'], defaultValue: ''),
      pageUrls: MapServices.get(map, ['pageUrls'], defaultValue: ''),
      coverUrl: MapServices.get(map, ['coverUrl'], defaultValue: ''),
      coverPath: MapServices.get(map, ['coverPath'], defaultValue: ''),
      date: DateTime.fromMillisecondsSinceEpoch(dateFromMillisecondsSinceEpoch),
      isAdult: MapServices.get(map, ['isAdult'], defaultValue: false),
      isCompleted: MapServices.get(map, ['isCompleted'], defaultValue: false),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'author': author,
    'translator': translator,
    'mc': mc,
    'tags': tags,
    'desc': desc,
    'pageUrls': pageUrls,
    'coverUrl': coverUrl,
    'coverPath': coverPath,
    'date': date.millisecondsSinceEpoch,
    'isAdult': isAdult,
    'isCompleted': isCompleted,
  };

  List<String> get getTags {
    final res = tags.split(',').toList();
    return res.where((e) => e.isNotEmpty).toList();
  }

  void setTags(List<String> values) {
    tags = values.join(',');
  }

  // page urls
  List<String> get getPageUrls {
    final res = pageUrls.split(',').toList();
    return res.where((e) => e.isNotEmpty).toList();
  }

  void setPageUrl(List<String> values) {
    pageUrls = values.join(',');
  }

  // new date
  void newDate() {
    date = DateTime.now();
  }

  String get getContentPath {
    return ServerFileServices.getContentDBFilesPath(id);
  }

  void delete() {
    final dbFile = File(getContentPath);
    if (dbFile.existsSync()) {
      dbFile.deleteSync();
    }
  }

  @override
  String toString() {
    return title;
  }
}
