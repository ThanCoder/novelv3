// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:than_pkg/than_pkg.dart';

import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';

class NovelPdf {
  final String path;
  NovelPdf({required this.path});

  factory NovelPdf.createPath(String path) {
    return NovelPdf(path: path);
  }
  NovelPdf copyWith({String? path}) {
    return NovelPdf(path: path ?? this.path);
  }

  static bool isPdf(String path) {
    return path.endsWith('.pdf');
  }

  // get
  String get getTitle {
    return path.getName();
  }

  String get getParentPath => File(path).parent.path;

  String get getBookmarkPath =>
      '$getParentPath/${path.getName(withExt: false)}.bookmark.config.json';

  String get getConfigPath =>
      '$getParentPath/${path.getName(withExt: false)}.-v3-config.json';

  DateTime get getDate {
    final file = File(path);
    return file.statSync().modified;
  }

  String get getSize {
    final file = File(path);
    return file.statSync().size.toDouble().toFileSizeLabel();
  }

  String get getCoverPath {
    return '${PathUtil.getCachePath()}/$getTitle.png';
  }

  Future<NovelPdf> renameTitle(String title) async {
    final file = File(path);
    final newPath = '${file.parent.path}/$title';
    await file.rename(newPath);
    final newPdf = copyWith(path: newPath);
    // rename config
    final configFile = File(getConfigPath);
    if (configFile.existsSync()) {
      await configFile.rename(newPdf.getConfigPath);
    }
    return newPdf;
  }

  Future<void> rename(String newPath) async {
    final file = File(path);
    await file.rename(newPath);
  }

  Future<void> copy(String newPath) async {
    final file = File(path);
    final newFile = File(newPath);
    if (newFile.existsSync()) return;
    await file.copy(newPath);
  }

  Future<void> delete() async {
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
