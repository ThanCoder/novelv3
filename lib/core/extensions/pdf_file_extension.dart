import 'package:novel_v3/core/models/pdf_file.dart';

extension PdfFileExtension on List<PdfFile> {
  void sortTitle({bool aToZ = true}) {
    sort((a, b) {
      if (aToZ) {
        // A → Z
        return a.title.compareTo(b.title);
      } else {
        // Z → A
        return b.title.compareTo(a.title);
      }
    });
  }

  void sortDate({bool isNewest = true}) {
    sort((a, b) {
      if (isNewest) {
        // newest
        if (a.date.millisecondsSinceEpoch > b.date.millisecondsSinceEpoch) {
          return -1;
        }
        if (a.date.millisecondsSinceEpoch < b.date.millisecondsSinceEpoch) {
          return 1;
        }
      } else {
        // oldest top
        if (a.date.millisecondsSinceEpoch > b.date.millisecondsSinceEpoch) {
          return 1;
        }
        if (a.date.millisecondsSinceEpoch < b.date.millisecondsSinceEpoch) {
          return -1;
        }
      }
      return 0;
    });
  }

  void sortSize({bool isSmallest = true}) {
    sort((a, b) {
      if (isSmallest) {
        // isSmallest
        if (a.getSize > b.getSize) {
          return 1;
        }
        if (a.getSize < b.getSize) {
          return -1;
        }
      } else {
        // is largest

        if (a.getSize > b.getSize) {
          return -1;
        }
        if (a.getSize < b.getSize) {
          return 1;
        }
      }
      return 0;
    });
  }
}
