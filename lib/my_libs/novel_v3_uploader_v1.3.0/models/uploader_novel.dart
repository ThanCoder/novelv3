import 'dart:convert';
import 'dart:io';
import 'package:t_widgets/extensions/string_extension.dart';
import 'package:than_pkg/services/map_services.dart';
import 'package:uuid/uuid.dart';

import '../services/server_file_services.dart';

class UploaderNovel {
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
  UploaderNovel({
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

  factory UploaderNovel.create({
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
    return UploaderNovel(
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

  factory UploaderNovel.fromMapWithUrl(Map<String, dynamic> map) {
    final novel = UploaderNovel.fromMap(map);
    novel.coverUrl = ServerFileServices.getImageUrl('${novel.id}.png');
    return novel;
  }
  // config file
  factory UploaderNovel.fromV3ConfigFile(String path) {
    final file = File(path);
    final map = jsonDecode(file.readAsStringSync());
    final config = UploaderNovel.fromV3Map(map);
    config.coverPath =
        '${file.parent.path}/${path.getName().replaceAll('.config.json', '.png')}';
    return config;
  }

  factory UploaderNovel.fromV3Map(Map<String, dynamic> map) {
    final dateFromMillisecondsSinceEpoch = MapServices.get<int>(map, [
      'date',
    ], defaultValue: 0);

    return UploaderNovel(
      id: MapServices.get(map, ['id'], defaultValue: const Uuid().v4()),
      title: MapServices.get(map, ['title'], defaultValue: 'Untitled'),
      author: MapServices.get(map, ['author'], defaultValue: 'Unknown'),
      translator: MapServices.get(map, ['translator'], defaultValue: 'Unknown'),
      mc: MapServices.get(map, ['mc'], defaultValue: 'Unknown'),
      tags: MapServices.get(map, ['tags'], defaultValue: ''),
      desc: MapServices.get(map, ['content'], defaultValue: ''),
      pageUrls: MapServices.get(map, ['page_link'], defaultValue: ''),
      coverUrl: MapServices.get(map, ['coverUrl'], defaultValue: ''),
      coverPath: MapServices.get(map, ['coverPath'], defaultValue: ''),
      date: DateTime.fromMillisecondsSinceEpoch(dateFromMillisecondsSinceEpoch),
      isAdult: MapServices.get(map, ['is_adult'], defaultValue: false),
      isCompleted: MapServices.get(map, ['is_completed'], defaultValue: false),
    );
  }

  // map
  factory UploaderNovel.fromMap(Map<String, dynamic> map) {
    final dateFromMillisecondsSinceEpoch = MapServices.get<int>(map, [
      'date',
    ], defaultValue: 0);

    return UploaderNovel(
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

  Map<String, dynamic> get toMap => {
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
