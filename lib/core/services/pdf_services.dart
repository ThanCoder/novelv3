import 'dart:io';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:novel_v3/core/models/pdf_file.dart';
import 'package:than_pkg/than_pkg.dart' show ThanPkg;

class PdfServices {
  PdfServices._();
  static final instance = PdfServices._();
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

  Future<void> delete(PdfFile pdf) async {
    await pdf.deleteForever();
  }

  Future<void> genPdfThumbnail(
    PdfFile pdf,
    String savePath, {
    bool saveOverride = false,
    bool runInBackground = false,
    double width = 800,
    double height = 1200,
    int quality = 75,
  }) async {
    final saveFile = File(savePath);
    if (saveFile.existsSync() && !saveOverride) return;

    if (Platform.isAndroid) {
      await ThanPkg.android.thumbnail.genPdfImage(
        pdfPath: pdf.path,
        outPath: savePath,
      );
      return;
    }
    // final bytes = await getPdfImage(
    //   pdf.path,
    //   0,
    //   width: width.toInt(),
    //   height: height.toInt(),
    // );
    // if (bytes == null) return;
    // await saveFile.writeAsBytes(bytes);
  }
}
