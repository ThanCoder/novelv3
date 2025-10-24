import 'dart:io';

import 'package:novel_v3/more_libs/setting_v2.0.0/others/path_util.dart';

import 'database.dart';

abstract class FolderDatabase<T> extends Database<T> {
  FolderDatabase({required super.root});

  T? from(FileSystemEntity file);
  String getId(T value);

  final List<T> _list = [];

  void clearCacheList() {
    _list.clear();
  }

  @override
  Future<List<T>> getAll({Map<String, dynamic>? query}) async {
    // query = query ?? {};
    // final isUsedCache = query.getBool(['isUsedCache']);
    // if (isUsedCache && _list.isNotEmpty) return _list;

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
    final index = _list.indexWhere((e) => getId(e) == id);
    if (index != -1) {
      _list.removeAt(index);
    }
    final dir = Directory('$root/$id');
    if (!dir.existsSync()) throw Exception('${dir.path} Not Found!');
    await PathUtil.deleteDir(dir);
    notify(DatabaseListenerEvent.delete, id: id);
  }

  @override
  Future<void> add(T value) async {
    // final dir = Directory('$root/${getId(value)}');
    // if (!dir.existsSync()) {
    //   throw Exception('${dir.path} Already Exists');
    // }
    _list.insert(0, value);
    notify(DatabaseListenerEvent.add, id: getId(value));
  }

  @override
  Future<void> update(String id, T value) async {
    final dir = Directory('$root/$id');
    if (!dir.existsSync()) throw Exception('${dir.path} Not Found!');
  }
}
