import 'dart:io';

import 'package:novel_v3/app/core/interfaces/file_scanner_interface.dart';
import 'package:novel_v3/app/others/n3_data/n3_data.dart';

class N3DataScanner extends FileScannerInterface<N3Data> {
  static final N3DataScanner _instance = N3DataScanner._();
  N3DataScanner._();
  factory N3DataScanner() => _instance;

  @override
  Future<N3Data?> onParseFile(FileSystemEntity file) async {
    if (!file.path.endsWith('.${N3Data.getExt}')) return null;
    final data = N3Data.createPath(file.path);
    return data;
  }
}
