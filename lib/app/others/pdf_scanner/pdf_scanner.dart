import 'dart:io';

import 'package:novel_v3/app/core/interfaces/file_scanner_interface.dart';
import 'package:novel_v3/app/core/models/pdf_file.dart';
import 'package:novel_v3/app/others/pdf_scanner/pdf_extension.dart';

class PdfScanner extends FileScannerInterface<PdfFile> {
  static final PdfScanner _instance = PdfScanner._();
  PdfScanner._();
  factory PdfScanner() => _instance;

  @override
  Future<PdfFile?> onParseFile(FileSystemEntity file) async {
    if (!PdfFile.isPdfFile(file.path)) return null;
    return PdfFile.createPath(file.path);
  }

  @override
  void onSort(List<PdfFile> list) {
    list.sortDate();
  }
}
