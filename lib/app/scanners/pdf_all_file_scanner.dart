import 'dart:io';

import 'package:novel_v3/app/core/interfaces/all_file_scanner_interface.dart';
import 'package:novel_v3/app/core/models/novel_pdf.dart';

class PdfAllFileScanner extends AllFileScannerInterface<NovelPdf> {
  @override
  NovelPdf? onParseFile(FileSystemEntity file) {
    if (NovelPdf.isPdf(file.path)) {
      return NovelPdf.createPath(file.path);
    }
    return null;
  }
}
