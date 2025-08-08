// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:than_pkg/than_pkg.dart';

class Chapter {
  int number;
  String path;
  Chapter({
    required this.number,
    required this.path,
  });

  factory Chapter.createPath(String path) {
    final number = int.parse(path.getName());
    return Chapter(number: number, path: path);
  }
  String get getNovelPath{
    return Directory(path).parent.path;
  }

  String getTitle({int readLine = 0}) {
    final file = File(path);
    if (file.existsSync()) {
      final lines = file.readAsLinesSync();
      if (lines.isEmpty || lines.length < readLine) {
        return '';
      }
      return lines[readLine];
    }
    return '';
  }

  String get getContents {
    final file = File(path);
    if (file.existsSync()) {
      return file.readAsStringSync();
    }
    return '';
  }

  static bool isChapter(String path) {
    final number = int.tryParse(path.getName());
    return number == null ? false : true;
  }
}
