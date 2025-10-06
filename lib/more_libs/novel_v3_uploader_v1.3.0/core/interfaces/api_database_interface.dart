import '../../novel_v3_uploader.dart';

abstract class ApiDatabaseInterface<T> extends JsonDatabaseInterface<T> {
  ApiDatabaseInterface({required super.root, required super.storage});

  @override
  Future<String> getDBContent(String sourceRoot) async {
    return await NovelV3Uploader.instance.getContentFromUrl!(sourceRoot);
  }
}
