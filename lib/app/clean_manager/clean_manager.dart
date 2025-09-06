import 'dart:io';

abstract class CleanManager {
  final Directory root;
  CleanManager({required this.root});
  Future<CacheData> getCacheInfo();

  Future<void> clean(CacheData cacheData) async {
    for (var file in cacheData.files) {
      if (!file.existsSync()) continue;
      await file.delete(recursive: true);
    }
  }
}

class CacheData {
  final int count;
  final String size;
  final List<FileSystemEntity> files;
  CacheData({required this.count, required this.size, required this.files});
}
