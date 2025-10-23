import 'dart:typed_data';

abstract class Storage {
  final String root;
  Storage({required this.root});

  String getPath(String id) {
    return '$root/$id';
  }

  Future<List<String>> getList();
  Future<Uint8List?> read(String id);
  Future<bool> write(String id, Uint8List data);
  Future<bool> delete(String id);
}
