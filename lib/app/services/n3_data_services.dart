import 'package:novel_v3/app/factorys/all_file_scanner_factory.dart';
import 'package:novel_v3/app/n3_data/n3_data.dart';

class N3DataServices {
  static Future<List<N3Data>> getScanList() async {
    return await AllFileScannerFactory.getScanner<N3Data>().scanList();
  }
}
