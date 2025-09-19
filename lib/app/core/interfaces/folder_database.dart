import 'dart:io';

import 'package:novel_v3/more_libs/setting_v2.0.0/others/path_util.dart';

import 'database.dart';

abstract class FolderDatabase<T> extends Database<T> {
  FolderDatabase({required super.root, required super.storage});

  T? from(FileSystemEntity file);

  @override
  Future<List<T>> getAll({Map<String, dynamic> query = const {}}) async {
    List<T> list = [];
    final dir = Directory(root);
    if (!dir.existsSync()) return list;
    for (var file in dir.listSync(followLinks: false)) {
      final fileT = from(file);
      if (fileT == null) continue;
      list.add(fileT);
    }
    return list;
  }

  @override
  Future<void> delete(String id) async {
    final dir = Directory('$root/$id');
    if (!dir.existsSync()) return;
    await PathUtil.deleteDir(dir);
  }
}
