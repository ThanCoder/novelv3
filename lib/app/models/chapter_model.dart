import 'dart:io';

import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:novel_v3/app/text_reader/text_reader_data_interface.dart';

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
    final file = File(path.replaceAll('$number', '${number + 1}'));
    return file.existsSync();
  }

  @override
  bool isExistsPrev() {
    final file = File(path.replaceAll('$number', '${number - 1}'));
    return file.existsSync();
  }

  @override
  ChapterModel getNext() {
    String _path = path.replaceAll('$number', '${number + 1}');
    return ChapterModel.fromPath(_path);
  }

  @override
  ChapterModel getPrev() {
    String _path = path.replaceAll('$number', '${number - 1}');
    return ChapterModel.fromPath(_path);
  }

  void delete() {
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  String get getConfigPath => '${File(path).parent.path}/$textReaderConfigName';
  String get getNovelPath => File(path).parent.path;

  @override
  String toString() {
    return '\ntitle => $title \npath => $path';
  }
}
