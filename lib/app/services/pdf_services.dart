import 'dart:io';

import 'package:mime/mime.dart';
import 'package:novel_v3/app/models/pdf_model.dart';

class PdfServices {
  static final PdfServices instance = PdfServices._();
  PdfServices._();
  factory PdfServices() => instance;

  Future<List<PdfModel>> getList({required String novelPath}) async {
    List<PdfModel> list = [];
    final dir = Directory(novelPath);
    if (!await dir.exists()) return [];
    for (var file in dir.listSync()) {
      if (file.statSync().type != FileSystemEntityType.file) continue;
      final mime = lookupMimeType(file.path);
      if (mime == null || !mime.startsWith('application/pdf')) continue;
      list.add(PdfModel.fromPath(file.path));
    }
    //sort
    list.sort((a, b) => a.title.compareTo(b.title));
    return list;
  }
}
