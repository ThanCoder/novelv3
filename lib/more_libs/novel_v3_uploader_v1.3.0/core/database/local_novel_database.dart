import '../../novel_v3_uploader.dart';

class LocalNovelDatabase extends LocalDatabaseInterface<Novel> {
  LocalNovelDatabase()
    : super(
        root: '${NovelV3Uploader.instance.getLocalServerPath()}/main.db.json',
        storage: Storage(
          root: '${NovelV3Uploader.instance.getLocalServerPath()}/images',
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
  
  @override
  Future<Novel?> getOne({Map<String, dynamic> query = const {}}) {
    // TODO: implement getOne
    throw UnimplementedError();
  }
}
