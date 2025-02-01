// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/utils/app_util.dart';
import 'package:novel_v3/app/utils/path_util.dart';

class PdfFileModel {
  String title;
  String path;
  int size;
  int date;
  late String bookMarkPath;
  late String configPath;
  late String configOldPath;
  late String coverPath;

  PdfFileModel({
    required this.title,
    required this.path,
    required this.size,
    required this.date,
  }) {
    bookMarkPath = path.replaceAll('.pdf', pdfBookListName);
    configPath = path.replaceAll('.pdf', pdfConfigName);
    configOldPath = path.replaceAll('.pdf', '-config.json');
    coverPath = '$path.png';
  }

  factory PdfFileModel.fromPath(String path) {
    final file = File(path);
    final pdfFile = PdfFileModel(
      title: getBasename(path),
      path: path,
      size: file.lengthSync(),
      date: file.statSync().modified.millisecondsSinceEpoch,
    );
    return pdfFile;
  }
  void setFullPath(String newPath) {
    path = newPath;
    title = getBasename(path);
    bookMarkPath = path.replaceAll('.pdf', pdfBookListName);
    configPath = path.replaceAll('.pdf', pdfConfigName);
    configOldPath = path.replaceAll('.pdf', '-config.json');
    coverPath = '$path.png';
  }

  void changeFullPath(String newPath) {
    //old file
    final bookListFile = File(bookMarkPath);
    final configOldFile = File(configOldPath);
    final configV3File = File(configPath);
    final coverFile = File(coverPath);
    final pdfFile = File(path);
    //set new path
    setFullPath(newPath);
    //change newPath
    if (pdfFile.existsSync()) {
      pdfFile.renameSync(path);
    }
    if (bookListFile.existsSync()) {
      bookListFile.renameSync(bookMarkPath);
    }
    if (configOldFile.existsSync()) {
      configOldFile.renameSync(configOldPath);
    }
    if (configV3File.existsSync()) {
      configV3File.renameSync(configPath);
    }
    if (coverFile.existsSync()) {
      coverFile.renameSync(coverPath);
    }
  }

  @override
  String toString() {
    return '\ntitle => $title\npath => $path\nsize => $size\nsize label => ${getParseFileSize(size.toDouble())}\nbookMarkPath => $bookMarkPath\nconfigPath => $configPath\ncoverPath => $coverPath\n';
  }
}
