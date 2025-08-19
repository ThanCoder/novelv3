import 'dart:io';

import 'package:novel_v3/app/interfaces/all_file_scanner_interface.dart';
import 'package:novel_v3/app/n3_data/n3_data.dart';

class N3DataAllFileScanner extends AllFileScannerInterface<N3Data> {
  @override
  N3Data? onParseFile(FileSystemEntity file) {
    if (N3Data.isN3Data(file.path)) {
      return N3Data.createPath(file.path);
    }
    return null;
  }
}
