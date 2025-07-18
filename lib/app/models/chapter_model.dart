import 'dart:io';

import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/my_libs/text_reader/text_reader_data_interface.dart';
import 'package:than_pkg/than_pkg.dart';

class ChapterModel extends TextReaderDataInterface {
  String title;
  int number;
  String path;
  ChapterModel({
    required this.title,
    required this.number,
    required this.path,
  });

  factory ChapterModel.fromPath(String path) {
    File file = File(path);
    String name = file.path.getName();
    String title = '';
    if (file.readAsLinesSync().isNotEmpty) {
      title = file.readAsLinesSync().first;
    }
    return ChapterModel(
      number: int.tryParse(name) ?? 1,
      title: title,
      path: file.path,
    );
  }

  ChapterModel refreshData() {
    File file = File(path);
    String name = file.path.getName();
    String title = '';
    if (file.readAsLinesSync().isNotEmpty) {
      title = file.readAsLinesSync().first;
    }
    return ChapterModel(
      number: int.tryParse(name) ?? 1,
      title: title,
      path: file.path,
    );
  }

  static String getContentText(String path) {
    final file = File(path);
    if (!file.existsSync()) return '';
    return file.readAsStringSync();
  }

  @override
  String getContent() {
    final file = File(path);
    if (!file.existsSync()) return '';
    return file.readAsStringSync();
  }

  void setContent(String content) {
    final file = File(path);
    file.writeAsStringSync(content);
  }

  @override
  bool isExistsNext() {
    final file = File('$getNovelPath/${number + 1}');
    return file.existsSync();
  }

  @override
  bool isExistsPrev() {
    final file = File('$getNovelPath/${number - 1}');
    return file.existsSync();
  }

  @override
  ChapterModel getNext() {
    String _path = '$getNovelPath/${number + 1}';
    return ChapterModel.fromPath(_path);
  }

  @override
  ChapterModel getPrev() {
    String _path = '$getNovelPath/${number - 1}';
    return ChapterModel.fromPath(_path);
  }

  void delete() {
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  String getTitle({int readLine = 0}) {
    final file = File(path);
    if (!file.existsSync()) return title;

    final lines = file.readAsLinesSync();
    if (lines.length > readLine) {
      return lines[readLine];
    }
    return title;
  }

  String get getConfigPath => '${File(path).parent.path}/$textReaderConfigName';
  String get getNovelPath => File(path).parent.path;

  @override
  String toString() {
    return '\ntitle => $title \npath => $path';
  }
}
