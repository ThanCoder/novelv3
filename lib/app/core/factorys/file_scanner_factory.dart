import 'package:novel_v3/app/core/interfaces/file_scanner_interface.dart';
import 'package:novel_v3/app/others/n3_data/n3_data.dart';
import 'package:novel_v3/app/ui/novel_dir_app.dart';
import 'package:novel_v3/app/scanners/chapter_file_scanner.dart';
import 'package:novel_v3/app/scanners/n3_data_all_file_scanner.dart';
import 'package:novel_v3/app/scanners/novel_file_scanner.dart';
import 'package:novel_v3/app/scanners/pdf_file_scanner.dart';

class FileScannerFactory {
  static FileScannerInterface<T> getScanner<T>({bool novelIsAllCalc = false}) {
    // all file
    // file
    if (T == Novel) {
      return NovelFileScanner(isAllCalc: novelIsAllCalc)
          as FileScannerInterface<T>;
    } else if (T == NovelPdf) {
      return PdfFileScanner() as FileScannerInterface<T>;
    } else if (T == Chapter) {
      return ChapterFileScanner() as FileScannerInterface<T>;
    } else if (T == N3Data) {
      return N3DataAllFileScanner() as FileScannerInterface<T>;
    } else {
      throw UnimplementedError('not support type $T');
    }
  }
}
