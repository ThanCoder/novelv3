// ignore_for_file: public_member_api_docs, sort_constructors_first
abstract class Storage {
  final String root;
  Storage({required this.root});
  Future<void> write(String id, List<int> data);
  Future<void> writeStream(String id, Stream<List<int>> data, int bytesLength);
  Future<List<int>?> read(String id);
  Future<String?> getPath(String id);
  Future<List<String>> getList();
  Future<void> delete(String id);
}
