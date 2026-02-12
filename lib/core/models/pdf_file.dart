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

  String get getParentPath => File(path).parent.path;

  String get getCurrentConfigPath => getConfigPath(getParentPath, title);
  String get getCurrentBookmarkConfigPath =>
      getBookmarkPath(getParentPath, title);

  Future<void> renameAllConfig(String oldName) async {
    final oldFile = File(pathJoin(getParentPath, oldName));
    if (!oldFile.existsSync()) return;
    // rename
    await oldFile.rename(path);
    await _renameConfigName(oldName);
    await _renameBookmarkName(oldName);
  }

  Future<void> deleteForever() async {
    final pdfFile = File(path);
    final configFile = File(getCurrentConfigPath);
    final bookmarkFile = File(getCurrentBookmarkConfigPath);
    if (pdfFile.existsSync()) {
      await pdfFile.delete();
    }
    if (configFile.existsSync()) {
      await configFile.delete();
    }
    if (bookmarkFile.existsSync()) {
      await bookmarkFile.delete();
    }
  }

  Future<void> _renameConfigName(String oldName) async {
    final oldFile = File(getConfigPath(getParentPath, oldName));
    if (!oldFile.existsSync()) return;
    await oldFile.rename(getCurrentConfigPath);
  }

  Future<void> _renameBookmarkName(String oldName) async {
    final oldFile = File(getBookmarkPath(getParentPath, oldName));
    if (!oldFile.existsSync()) return;
    await oldFile.rename(getCurrentBookmarkConfigPath);
  }

  static String getConfigPath(String novelPath, String name) =>
      '$novelPath/${name.getName(withExt: false)}-v3-config.json';

  static String getBookmarkPath(String novelPath, String name) =>
      '$novelPath/${name.getName(withExt: false)}.bookmark.config.json';

  static bool isPdfFile(String path) => path.endsWith('.pdf');
}
