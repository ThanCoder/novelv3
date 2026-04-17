import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:novel_v3/core/models/pdf_file.dart';
import 'package:pdfrx_engine/pdfrx_engine.dart';
import 'package:image/image.dart' as img;
import 'package:than_pkg/than_pkg.dart';

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
    double width = 110,
    double height = 130,
    int quality = 75,
  }) async {
    final saveFile = File(savePath);
    if (saveFile.existsSync() && !saveOverride) return;

    if (runInBackground) {
      await compute(_genPdfThumbnailInBackground, (
        pdf.path,
        savePath,
        width,
        height,
      ));
    } else {
      if (Platform.isAndroid) {
        await ThanPkg.android.thumbnail.genPdfImage(
          pdfPath: pdf.path,
          outPath: savePath,
        );
        return;
      }
      await pdfrxInitialize();

      final document = await PdfDocument.openFile(pdf.path);
      final page = document.pages[0]; // first page
      final pageImage = await page.render(
        /// Standard size
        // fullWidth: (page.width * fullWidth / 72),
        // fullHeight: (page.height * fullHeight / 72),
        // for cover size
        fullWidth: width,
        fullHeight: height,
      );
      if (pageImage != null) {
        final image = pageImage.createImageNF();
        await saveFile.writeAsBytes(img.encodeJpg(image, quality: quality));
        pageImage.dispose();
      }
      await document.dispose();
    }
  }
}

Future<void> _genPdfThumbnailInBackground(
  (String, String, double, double) params,
) async {
  try {
    final path = params.$1;
    final cachePath = params.$1;
    double fullWidth = params.$3;
    double fullHeight = params.$4;

    await pdfrxInitialize();

    final cacheFile = File(cachePath);
    final document = await PdfDocument.openFile(path);
    final page = document.pages[0]; // first page
    final pageImage = await page.render(
      fullWidth: (page.width * fullWidth / 72),
      fullHeight: (page.height * fullHeight / 72),
    );
    if (pageImage != null) {
      final image = pageImage.createImageNF();
      await cacheFile.writeAsBytes(img.encodePng(image));
      pageImage.dispose();
    }
    await document.dispose();
  } catch (e) {
    debugPrint('[_genPdfThumbnailInBackground]: $e');
  }
}
