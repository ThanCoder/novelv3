import 'dart:io';

import 'package:novel_v3/core/interfaces/file_scanner_interface.dart';
import 'package:novel_v3/app/others/novl_db/novl_data.dart';
import 'package:novel_v3/app/others/novl_db/novl_db.dart';
import 'package:than_pkg/than_pkg.dart';

class NovlDataServices {
  static Future<List<NovlData>> getScanList() async {
    return await N3DataScanner().scan();
  }
}

class N3DataScanner extends FileScannerInterface<NovlData> {
  static final N3DataScanner _instance = N3DataScanner._();
  N3DataScanner._();
  factory N3DataScanner() => _instance;

  @override
  Future<NovlData?> onParseFile(FileSystemEntity file) async {
    if (!file.getName().endsWith('.${NovlDB.extName}')) return null;
    return await NovlData.fromPath(file.path);
  }
}
