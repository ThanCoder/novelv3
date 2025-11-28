import 'dart:io';

import 'package:novel_v3/app/core/models/pdf_file.dart';
import 'package:than_pkg/extensions/file_system_entity_extension.dart';

class PdfServices {
  static final PdfServices instance = PdfServices._();
  PdfServices._();
  factory PdfServices() => instance;

  Future<List<PdfFile>> getAll(String novelPath) async {
    List<PdfFile> list = [];
    final dir = Directory(novelPath);
    if (!dir.existsSync()) return list;
    for (var file in dir.listSync(followLinks: false)) {
      if (!file.isFile) continue;
      final title = file.getName();
      if (!PdfFile.isPdfFile(title)) continue;
      list.add(PdfFile.createPath(file.path));
    }

    return list;
  }
}
