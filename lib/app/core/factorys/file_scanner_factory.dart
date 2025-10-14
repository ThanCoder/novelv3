import 'package:novel_v3/app/core/interfaces/file_scanner_interface.dart';
import 'package:novel_v3/app/others/n3_data/n3_data.dart';
import 'package:novel_v3/app/ui/novel_dir_app.dart';
import 'package:novel_v3/app/scanners/chapter_file_scanner.dart';
import 'package:novel_v3/app/scanners/n3_data_all_file_scanner.dart';
import 'package:novel_v3/app/scanners/novel_file_scanner.dart';
import 'package:novel_v3/app/scanners/pdf_file_scanner.dart';

class FileScannerFactory {
  static final Map<String, FileScannerInterface> _cache = {};

  static FileScannerInterface<T> getScanner<T>({bool novelIsAllCalc = false}) {
    final key = '$T';

    if (_cache.containsKey(key)) {
      return _cache[key] as FileScannerInterface<T>;
    }
    late FileScannerInterface<T> scanner;
    // all file
    // file
    if (T == Novel) {
      scanner =
          NovelFileScanner(isAllCalc: novelIsAllCalc)
              as FileScannerInterface<T>;
    } else if (T == NovelPdf) {
      scanner = PdfFileScanner() as FileScannerInterface<T>;
    } else if (T == Chapter) {
      scanner = ChapterFileScanner() as FileScannerInterface<T>;
    } else if (T == N3Data) {
      scanner = N3DataAllFileScanner() as FileScannerInterface<T>;
    } else {
      throw UnimplementedError('not support type $T');
    }

    _cache[key] = scanner;
    return scanner;
  }
}
