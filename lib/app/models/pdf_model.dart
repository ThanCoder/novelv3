// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:than_pkg/than_pkg.dart';

class PdfModel {
  String title;
  String path;
  String coverPath;
  int size;
  DateTime date;
  String configPath;
  String bookMarkPath;
  PdfModel({
    required this.title,
    required this.path,
    required this.coverPath,
    required this.size,
    required this.date,
    this.bookMarkPath = '',
    this.configPath = '',
  });

  factory PdfModel.fromPath(
    String path, {
    String? coverPath,
    String? configPath,
    String? bookmarkPath,
  }) {
    final file = File(path);
    final name = file.path.getName(withExt: false);
    var cp = coverPath ?? file.path.replaceAll('.pdf', '.png');
    var config = configPath ?? file.path.replaceAll('.pdf', pdfConfigName);
    var bookmark =
        bookmarkPath ?? file.path.replaceAll('.pdf', pdfBookListName);

    return PdfModel(
      title: name,
      path: path,
      coverPath: cp,
      size: file.statSync().size,
      date: file.statSync().modified,
      configPath: config,
      bookMarkPath: bookmark,
    );
  }

  void delete() {
    final pdfFile = File(path);
    final coverFile = File(coverPath);
    final configFile = File(path);
    if (pdfFile.existsSync()) {
      pdfFile.deleteSync();
    }
    if (coverFile.existsSync()) {
      coverFile.deleteSync();
    }
    if (configFile.existsSync()) {
      configFile.deleteSync();
    }
  }

  PdfConfigModel getConfig() {
    return PdfConfigModel.fromPath(configPath);
  }

  void setConfig(PdfConfigModel config) {
    config.savePath(configPath);
  }

  @override
  String toString() {
    return title;
  }
}
