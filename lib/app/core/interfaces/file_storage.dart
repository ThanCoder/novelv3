import 'dart:io';

import 'package:than_pkg/than_pkg.dart';

import 'storage.dart';

class FileStorage extends Storage {
  FileStorage({required super.root});

  @override
  Future<void> delete(Pattern id) async {
    final file = File('$root/$id');
    await file.delete();
  }

  @override
  Future<List<String>> getList() async {
    final dir = Directory(root);
    if (!dir.existsSync()) return [];
    List<String> list = [];
    for (var file in dir.listSync(followLinks: false)) {
      if (!file.isFile) continue;
      list.add(file.path);
    }
    return list;
  }

  @override
  Future<String?> getPath(String id) async {
    return '$root/$id';
  }

  @override
  Future<List<int>?> read(String id) async {
    final file = File('$root/$id');
    if (!file.existsSync()) return null;
    return (await file.readAsBytes()).toList();
  }

  @override
  Future<void> write(String id, List<int> data) async {
    final file = File('$root/$id');
    await file.writeAsBytes(data);
  }

  @override
  Future<void> writeStream(String id, Stream<List<int>> data, int bytesLength) {
    // TODO: implement writeStream
    throw UnimplementedError();
  }
}
