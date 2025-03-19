// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:novel_v3/app/utils/path_util.dart';

class ChapterModel {
  String title;
  String path;
  ChapterModel({
    required this.title,
    required this.path,
  });

  factory ChapterModel.fromPath(String path) {
    return ChapterModel.fromFile(File(path));
  }
  factory ChapterModel.fromFile(File file) {
    return ChapterModel(title: PathUtil.instance.getBasename(file.path), path: file.path);
  }

  @override
  String toString() {
    return '\ntitle => $title \npath => $path';
  }
}
