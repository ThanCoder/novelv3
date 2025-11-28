import 'dart:io';

import 'package:novel_v3/app/core/interfaces/file_scanner_interface.dart';
import 'package:novel_v3/app/core/models/pdf_file.dart';

class PdfScanner extends FileScannerInterface<PdfFile> {
  @override
  Future<PdfFile?> onParseFile(FileSystemEntity file) async {
    if (!PdfFile.isPdfFile(file.path)) return null;
    return PdfFile.createPath(file.path);
  }
}
