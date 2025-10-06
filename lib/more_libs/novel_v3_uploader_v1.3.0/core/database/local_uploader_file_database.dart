import '../../novel_v3_uploader.dart';

class LocalUploaderFileDatabase extends LocalDatabaseInterface<UploaderFile> {
  LocalUploaderFileDatabase(String novelId)
    : super(
        root:
            '${NovelV3Uploader.instance.getLocalServerPath()}/content_db/$novelId.db.json',
        storage: Storage(
          root: '${NovelV3Uploader.instance.getLocalServerPath()}/files',
        ),
      );

  @override
  Future<void> add(UploaderFile value) async {
    await UploaderFileServices.getLocalHistoryDatabase.add(value);
    return super.add(value);
  }

  @override
  Future<void> delete(String id) async {
    await UploaderFileServices.getLocalHistoryDatabase.delete(id);
    return super.delete(id);
  }

  @override
  Future<void> update(String id, UploaderFile value) async {
    await UploaderFileServices.getLocalHistoryDatabase.update(id, value);
    return super.update(id, value);
  }

  @override
  UploaderFile fromMap(Map<String, dynamic> map) {
    return UploaderFile.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(UploaderFile value) {
    return value.toMap();
  }

  @override
  String getId(UploaderFile value) {
    return value.id;
  }
}
