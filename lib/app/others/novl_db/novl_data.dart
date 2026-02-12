import 'dart:io';

import 'package:novel_v3/core/models/novel_meta.dart';
import 'package:novel_v3/app/others/novl_db/novl_db.dart';
import 'package:novel_v3/app/others/novl_db/novl_info.dart';
import 'package:than_pkg/extensions/file_system_entity_extension.dart';

class NovlData {
  final String title;
  final String path;
  final DateTime date;
  final int size;
  final NovelMeta novelMeta;
  final NovlInfo info;
  final String type;
  NovlData({
    required this.title,
    required this.path,
    required this.date,
    required this.size,
    required this.novelMeta,
    required this.info,
    required this.type,
  });

  static Future<NovlData?> fromPath(String path) async {
    if (!await NovlDB.isDBFile(path)) return null;
    final type = await NovlDB.readType(path);
    final file = File(path);
    final info = await NovlDB.readNovlInfo(path);
    if (info == null) return null;
    final meta = await NovlDB.readNovelMeta(path);
    if (meta == null) return null;
    return NovlData(
      title: file.getName(),
      path: path,
      date: file.getDate,
      size: file.getSize,
      info: info,
      novelMeta: meta,
      type: type!,
    );
  }

  Future<void> saveCover(String savePath) async {
    final file = File(savePath);
    if (file.existsSync()) return;

    final data = await NovlDB.getCoverData(path);
    if (data != null) {
      await file.writeAsBytes(data);
    }
  }

  Future<void> deleteForever() async {
    final file = File(path);
    if (!file.existsSync()) return;
    await file.delete();
  }
}
