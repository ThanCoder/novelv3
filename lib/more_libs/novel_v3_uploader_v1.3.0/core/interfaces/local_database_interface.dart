import 'index.dart';

abstract class LocalDatabaseInterface<T> extends JsonDatabaseInterface<T> {
  LocalDatabaseInterface({required super.root, required super.storage});

  @override
  Future<String> getDBContent(String sourceRoot) async {
    return await io.read(sourceRoot);
  }
}
