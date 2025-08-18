import 'dart:convert';
import 'dart:io';

import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:than_pkg/than_pkg.dart';

class Novel {
  String title;
  String path;
  DateTime date;
  int cacheSize = 0;
  bool cacheIsExistsDesc = false;
  bool cacheIsOnlineExists = false;

  Novel({required this.title, required this.path, required this.date});

  factory Novel.createTitle(String title) {
    final dir = Directory('${PathUtil.getSourcePath()}/$title');
    dir.createSync(recursive: true);
    return Novel.fromPath(dir.path);
  }

  factory Novel.fromPath(String path) {
    final dir = Directory(path);
    return Novel(
      title: path.getName(),
      path: path,
      date: dir.statSync().modified,
    );
  }
  // set list
  void setPageUrls(List<String> list) {
    final contents = list.join(',');
    _setFileContent('link', contents);
  }

  void setTags(List<String> list) {
    final contents = list.join(',');
    _setFileContent('tags', contents);
  }

  // get list
  List<String> get getPageUrls {
    final content = getPageUrlContent;
    final list = content.split(',').where((e) => e.isNotEmpty).toList();
    return list;
  }

  List<String> get getTags {
    final content = getTagContent;
    final list = content.split(',').where((e) => e.isNotEmpty).toList();
    return list;
  }

  // set
  void setAuthor(String text) {
    _setFileContent('author', text);
  }

  void setTranslator(String text) {
    _setFileContent('translator', text);
  }

  void setMC(String text) {
    _setFileContent('mc', text);
  }

  void setContent(String text) {
    _setFileContent('content', text);
  }

  void setTagContent(String text) {
    _setFileContent('tags', text);
  }

  void setPageUrlContent(String text) {
    _setFileContent('link', text);
  }

  void setReaded(String text) {
    _setFileContent('readed', text);
  }

  // get
  String get getCoverPath {
    return '$path/cover.png';
  }

  String get getAuthor {
    return _getFileContent('author', defaultValue: 'Unknown');
  }

  String get getTranslator {
    return _getFileContent('translator', defaultValue: 'Unknown');
  }

  String get getMC {
    return _getFileContent('mc', defaultValue: 'Unknown');
  }

  String get getContent {
    return _getFileContent('content');
  }

  String get getTagContent {
    return _getFileContent('tags');
  }

  String get getPageUrlContent {
    return _getFileContent('link');
  }

  String get getReaded {
    return _getFileContent('readed', defaultValue: '0');
  }

  int get getReadedNumber {
    if (int.tryParse(getReaded) != null) {
      return int.parse(getReaded);
    }
    return 0;
  }

  // set title
  Future<void> setTitle(String newTitle) async {
    if (title != newTitle) {
      // rename title
      final oldDir = Directory(path);
      final newDir = Directory('${oldDir.parent.path}/$newTitle');
      if (newDir.existsSync()) {
        throw Exception('title ရှိနေပြီးသား ဖြစ်နေပါတယ်');
      }
      // အတူဘူးဆိုရင်
      await newDir.create(recursive: true);
      title = newTitle;
      path = newDir.path;

      // move old dir
      for (var file in oldDir.listSync()) {
        final newPath = '${newDir.path}/${file.getName()}';
        await file.rename(newPath);
      }
      // delete old dir
      await oldDir.delete(recursive: true);
    }
  }

  Future<void> onSave() async {}

  // set bool
  void setAdult(bool isEnable) {
    final file = File('$path/is-adult');
    // enable ဖြစ်ပြီးတော့ file မရှိရင် ဖန်တီးမယ်
    if (isEnable && !file.existsSync()) {
      file.writeAsStringSync('');
    }
    // enable == false ဖြစ်နေပြီးတော့ file ရှိနေရင် ဖျက်မယ်
    if (!isEnable && file.existsSync()) {
      file.deleteSync();
    }
  }

  void setCompleted(bool isEnable) {
    final file = File('$path/is-completed');
    // enable ဖြစ်ပြီးတော့ file မရှိရင် ဖန်တီးမယ်
    if (isEnable && !file.existsSync()) {
      file.writeAsStringSync('');
    }
    // enable == false ဖြစ်နေပြီးတော့ file ရှိနေရင် ဖျက်မယ်
    if (!isEnable && file.existsSync()) {
      file.deleteSync();
    }
  }

  Future<void> deleteAll() async {
    final oldDir = Directory(path);
    if (!oldDir.existsSync()) return;
    for (var file in oldDir.listSync()) {
      await file.delete();
    }
    await oldDir.delete();
  }

  // get bool
  bool get isAdult {
    final file = File('$path/is-adult');
    return file.existsSync();
  }

  bool get isCompleted {
    final file = File('$path/is-completed');
    return file.existsSync();
  }

  bool get isExistsDesc {
    final file = File('$path/is-completed');
    return file.existsSync();
  }

  bool isExistsNovelData({String ext = 'npz'}) {
    final file = File('${PathUtil.getOutPath()}/$title.$ext');
    return file.existsSync();
  }

  String _getFileContent(String name, {String defaultValue = ''}) {
    final file = File('$path/$name');
    if (file.existsSync()) {
      return file.readAsStringSync();
    }
    return defaultValue;
  }

  void _setFileContent(String name, String contents) {
    final file = File('$path/$name');
    file.writeAsStringSync(contents);
  }

  int get getSizeInt {
    return cacheSize;
  }

  String get getContentPath => '$path/content';

  Future<String> getAllSizeLabel() async {
    if (cacheSize > 0) {
      return cacheSize.toDouble().toFileSizeLabel();
    }
    final size = await getAllSize();
    return size.toDouble().toFileSizeLabel();
  }

  Future<int> getAllSize() async {
    if (cacheSize > 0) return cacheSize;

    final dir = Directory(path);
    if (!dir.existsSync()) return 0;
    int size = 0;
    for (var file in dir.listSync(followLinks: false)) {
      if (file is File) {
        size += await file.length();
      }
    }
    cacheSize = size;
    return size;
  }

  Future<String> getConfigJson() async {
    final map = {};
    map['title'] = title;
    map['author'] = getAuthor;
    map['translator'] = getTranslator;
    map['mc'] = getMC;
    map['tags'] = getTagContent;
    map['pageUrls'] = getPageUrlContent;
    map['isCompleted'] = isCompleted;
    map['isAdult'] = isAdult;
    map['desc'] = getContent;

    return JsonEncoder.withIndent(' ').convert(map);
  }

  @override
  String toString() => 'Novel(title: $title, path: $path, date: $date)';
}
