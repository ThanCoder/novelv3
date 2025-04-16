import 'dart:io';
import 'package:novel_v3/app/extensions/string_extension.dart';
import 'package:novel_v3/app/services/index.dart';

class NovelDataModel {
  String title;
  String path;
  String coverPath;
  int size;
  int date;
  bool isAdult;
  bool isCompleted;
  bool isAlreadyExists;

  NovelDataModel({
    required this.title,
    required this.path,
    required this.coverPath,
    required this.size,
    required this.date,
    this.isAdult = false,
    this.isCompleted = false,
    this.isAlreadyExists = false,
  });

  factory NovelDataModel.fromPath(String path, {String? coverPath}) {
    final file = File(path);

    return NovelDataModel(
      title: path.getName(withExt: false),
      path: path,
      coverPath: coverPath ?? '',
      size: file.statSync().size,
      date: file.statSync().modified.millisecondsSinceEpoch,
      isAdult: NovelDataServices.instance.dataCheckIsAdult(dataFilePath: path),
      isCompleted:
          NovelDataServices.instance.dataCheckIsCompleted(dataFilePath: path),
    );
  }

  @override
  String toString() {
    return '\ntitle => $title\npath => $path\nsize => $size\ncoverPath => $coverPath\n';
  }
}
