import 'package:novel_v3/app/core/interfaces/all_file_scanner_interface.dart';
import 'package:novel_v3/app/others/n3_data/n3_data.dart';
import 'package:novel_v3/app/scanners/n3_data_all_file_scanner.dart';
import 'package:novel_v3/app/scanners/pdf_all_file_scanner.dart';
import 'package:novel_v3/app/core/models/novel_pdf.dart';

class AllFileScannerFactory {
  static final Map<String, AllFileScannerInterface> _cache = {};

  static AllFileScannerInterface<T> getScanner<T>() {
    final key = '$T';

    if (_cache.containsKey(key)) {
      return _cache[key] as AllFileScannerInterface<T>;
    }
    late AllFileScannerInterface<T> scanner;
    // all file

    if (T == NovelPdf) {
      scanner = PdfAllFileScanner() as AllFileScannerInterface<T>;
    } else if (T == N3Data) {
      scanner = N3DataAllFileScanner() as AllFileScannerInterface<T>;
    } else {
      throw UnimplementedError('not support type $T');
    }

    _cache[key] = scanner;
    return scanner;
  }
}
