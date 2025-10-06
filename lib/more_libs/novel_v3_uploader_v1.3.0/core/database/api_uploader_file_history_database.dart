import '../../novel_v3_uploader.dart';

class ApiUploaderFileHistoryDatabase
    extends ApiDatabaseInterface<UploaderFile> {
  ApiUploaderFileHistoryDatabase()
    : super(
        root:
            '${NovelV3Uploader.instance.getApiServerUrl()}/uploader-file-history.db.json',
        storage: Storage(
          root: '${NovelV3Uploader.instance.getApiServerUrl()}/files',
        ),
      );

  @override
  UploaderFile fromMap(Map<String, dynamic> map) {
    return UploaderFile.fromMap(map);
  }

  @override
  String getId(UploaderFile value) {
    return value.id;
  }

  @override
  Map<String, dynamic> toMap(UploaderFile value) {
    return value.toMap();
  }
}
