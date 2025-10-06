import '../../novel_v3_uploader.dart';

class ApiNovelDatabase extends ApiDatabaseInterface<Novel> {
  ApiNovelDatabase()
    : super(
        root: '${NovelV3Uploader.instance.getApiServerUrl()}/main.db.json',
        storage: Storage(
          root: '${NovelV3Uploader.instance.getApiServerUrl()}/images',
        ),
      );

  @override
  Novel fromMap(Map<String, dynamic> map) {
    return Novel.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(Novel value) {
    return value.toMap();
  }

  @override
  String getId(Novel value) {
    return value.id;
  }
  
}
