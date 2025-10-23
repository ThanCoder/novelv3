import 'dart:io';

import 'package:novel_v3/more_libs/setting_v2.0.0/others/path_util.dart';
import 'package:than_pkg/services/t_map.dart';

import 'database.dart';

abstract class FolderDatabase<T> extends Database<T> {
  FolderDatabase({required super.root});

  T? from(FileSystemEntity file);
  String getId(T value);

  final List<T> _list = [];

  @override
  Future<List<T>> getAll({Map<String, dynamic>? query}) async {
    query = query ?? {};
    final isUsedCache = query.getBool(['isUsedCache']);
    if (isUsedCache && _list.isNotEmpty) return _list;

    final dir = Directory(root);
    if (!dir.existsSync()) return _list;
    _list.clear();
    for (var file in dir.listSync(followLinks: false)) {
      final fileT = from(file);
      if (fileT == null) continue;
      _list.add(fileT);
    }
    return _list;
  }

  @override
  Future<void> delete(String id) async {
    final dir = Directory('$root/$id');
    if (!dir.existsSync()) return;
    await PathUtil.deleteDir(dir);
  }

  @override
  Future<void> add(T value) {
    throw UnimplementedError();
  }

  @override
  Future<T?> getById({required String id}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> update(String id, T value) async {
    throw UnimplementedError();
  }
}
