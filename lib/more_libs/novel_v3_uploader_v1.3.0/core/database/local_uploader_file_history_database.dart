import '../../novel_v3_uploader.dart';

class LocalUploaderFileHistoryDatabase
    extends LocalDatabaseInterface<UploaderFile> {
  LocalUploaderFileHistoryDatabase()
    : super(
        root:
            '${NovelV3Uploader.instance.getLocalServerPath()}/uploader-file-history.db.json',
        storage: Storage(
          root: '${NovelV3Uploader.instance.getLocalServerPath()}/files',
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

  @override
  Future<void> add(UploaderFile value) async {
    final list = await getAll();
    final index = list.indexWhere((e) => e.id == value.id);
    // ရှိနေရင် ဖျက်မယ်
    if (index != -1) {
      list.removeAt(index);
    }
    list.insert(0, value);
    notify(null, DatabaseListenerTypes.added);
    await save(root, list);
  }
}
