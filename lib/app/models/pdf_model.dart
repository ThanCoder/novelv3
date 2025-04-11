// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/extensions/index.dart';

class PdfModel {
  String title;
  String path;
  String coverPath;
  int size;
  int date;
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

  factory PdfModel.fromPath(String path) {
    final file = File(path);
    final name = file.path.getName(withExt: false);
    return PdfModel(
      title: name,
      path: path,
      coverPath: file.path.replaceAll('.pdf', '.png'),
      size: file.statSync().size,
      date: file.statSync().modified.millisecondsSinceEpoch,
      configPath: file.path.replaceAll('.pdf', pdfConfigName),
      bookMarkPath: file.path.replaceAll('.pdf', pdfBookListName),
    );
  }
  @override
  String toString() {
    return title;
  }
}
