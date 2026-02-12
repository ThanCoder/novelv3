
import 'package:novel_v3/core/models/pdf_file.dart';

extension PdfExtension on List<PdfFile> {
  void sortTitle({bool aToZ = true}) {
    sort((a, b) {
      if (aToZ) {
        // a -z
        return a.title.compareTo(b.title);
      } else {
        // z - a
        return b.title.compareTo(a.title);
      }
    });
  }

  void sortDate({bool isNewest = true}) {
    sort((a, b) {
      if (isNewest) {
        // newest
        if (a.date.millisecondsSinceEpoch >
            b.date.millisecondsSinceEpoch) {
          return -1;
        }
        if (a.date.millisecondsSinceEpoch <
            b.date.millisecondsSinceEpoch) {
          return 1;
        }
      } else {
        // oldest top
        if (a.date.millisecondsSinceEpoch >
            b.date.millisecondsSinceEpoch) {
          return 1;
        }
        if (a.date.millisecondsSinceEpoch <
            b.date.millisecondsSinceEpoch) {
          return -1;
        }
      }
      return 0;
    });
  }

}
