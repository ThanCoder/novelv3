import 'dart:io';

import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';
import 'package:t_widgets/extensions/double_extension.dart';
import 'package:than_pkg/extensions/string_extension.dart';

class NovelPdf {
  String path;
  NovelPdf({required this.path});

  factory NovelPdf.createPath(String path) {
    return NovelPdf(path: path);
  }

  static bool isPdf(String path) {
    return path.endsWith('.pdf');
  }

  String get getTitle {
    return path.getName();
  }

  String get getConfigPath {
    return path.replaceAll('.pdf', '-v3-config.json');
  }

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

  String get getParentPath {
    final file = File(path);
    return file.parent.path;
  }

  Future<void> rename(String newPath) async {
    final file = File(path);
    await file.rename(newPath);
    path = newPath;
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
