import 'dart:io';

import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:than_pkg/than_pkg.dart';

class PdfFile {
  final String title;
  final String path;
  final DateTime date;
  PdfFile({required this.title, required this.path, required this.date});

  PdfFile copyWith({String? title, String? path, DateTime? date}) {
    return PdfFile(
      title: title ?? this.title,
      path: path ?? this.path,
      date: date ?? this.date,
    );
  }

  factory PdfFile.createPath(String path) {
    final file = File(path);
    return PdfFile(title: path.getName(), path: path, date: file.getDate);
  }

  int get getSize => File(path).getSize;

  String get getCoverPath =>
      PathUtil.getCachePath(name: '${path.getName(withExt: false)}-cover.png');

  static String getConfigPath(String novelPath) => '$novelPath/v3-config.json';

  static bool isPdfFile(String path) => path.endsWith('.pdf');
}
