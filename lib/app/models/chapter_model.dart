import 'dart:io';

import 'package:novel_v3/app/extensions/index.dart';

class ChapterModel {
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
  String getContent() {
    final file = File(path);
    return file.readAsStringSync();
  }

  bool isExistNext() {
    final file = File(path.replaceAll('$number', '${number + 1}'));
    return file.existsSync();
  }

  bool isExistPrev() {
    final file = File(path.replaceAll('$number', '${number - 1}'));
    return file.existsSync();
  }

  ChapterModel getNext() {
    String _path = path.replaceAll('$number', '${number + 1}');
    return ChapterModel.fromPath(_path);
  }

  ChapterModel getPrev() {
    String _path = path.replaceAll('$number', '${number - 1}');
    return ChapterModel.fromPath(_path);
  }

  @override
  String toString() {
    return '\ntitle => $title \npath => $path';
  }
}
