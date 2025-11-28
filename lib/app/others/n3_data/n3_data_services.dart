import 'package:novel_v3/app/others/n3_data/n3_data.dart';
import 'package:novel_v3/app/others/n3_data/n3_data_scanner.dart';

class N3DataServices {
  static Future<List<N3Data>> getScanList() async {
    return await N3DataScanner().scan();
  }
}
