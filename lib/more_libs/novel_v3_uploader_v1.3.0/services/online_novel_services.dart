import 'dart:convert';
import 'dart:isolate';

import '../novel_v3_uploader.dart';

import '../constants.dart';

class OnlineNovelServices {
  static Future<List<UploaderNovel>> getNovelList() async {
    List<UploaderNovel> list = [];
    try {
      if (NovelV3Uploader.instance.onDownloadJson == null) {
        throw Exception(NovelV3Uploader.instance.getInitLog);
      }

      final res = await NovelV3Uploader.instance.onDownloadJson!(
        serverGitubDatabaseUrl,
      );
      return await Isolate.run<List<UploaderNovel>>(() async {
        List<dynamic> resList = jsonDecode(res);
        return resList.map((e) => UploaderNovel.fromMapWithUrl(e)).toList();
      });
    } catch (e) {
      NovelV3Uploader.instance.showLog(e.toString());
    }
    return list;
  }

  static Future<List<UploaderFile>> getFilesList({
    required String novelId,
  }) async {
    List<UploaderFile> list = [];
    try {
      if (NovelV3Uploader.instance.onDownloadJson == null) {
        throw Exception(NovelV3Uploader.instance.getInitLog);
      }
      final url = ServerFileServices.getContentDBUrl(novelId);
      final res = await NovelV3Uploader.instance.onDownloadJson!(url);
      List<dynamic> resList = jsonDecode(res);
      list = resList.map((e) => UploaderFile.fromMap(e)).toList();
    } catch (e) {
      NovelV3Uploader.instance.showLog(e.toString());
    }
    return list;
  }
}
