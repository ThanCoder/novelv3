import 'dart:io';
import 'dart:typed_data';

import 'storage.dart';

class FileStorage extends Storage {
  FileStorage({required super.root});

  @override
  Future<bool> delete(String id) async {
    final file = File('$root/$id');
    if (file.existsSync()) {
      await file.delete();
      return true;
    }
    return false;
  }

  @override
  Future<List<String>> getList() async {
    final dir = Directory(root);
    List<String> list = [];
    for (var file in dir.listSync(followLinks: false)) {
      list.add(file.path);
    }
    return list;
  }

  @override
  String getPath(String id) {
    return '$root/$id';
  }

  @override
  Future<Uint8List?> read(String id) async {
    final file = File('$root/$id');
    if (file.existsSync()) {
      return file.readAsBytesSync();
    }
    return null;
  }

  @override
  Future<bool> write(String id, Uint8List data) async {
    final file = File('$root/$id');
    await file.writeAsBytes(data);
    return false;
  }
}
