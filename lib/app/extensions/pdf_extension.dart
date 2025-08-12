import 'package:novel_v3/app/novel_dir_app.dart';

extension PdfExtension on List<NovelPdf> {
  void sortTitle({bool aToZ = true}) {
    sort((a, b) {
      if (aToZ) {
        // a -z
        return a.getTitle.compareTo(b.getTitle);
      } else {
        // z - a
        return b.getTitle.compareTo(a.getTitle);
      }
    });
  }

  void sortDate({bool isNewest = true}) {
    sort((a, b) {
      if (isNewest) {
        // newest
        if (a.getDate.millisecondsSinceEpoch >
            b.getDate.millisecondsSinceEpoch) {
          return -1;
        }
        if (a.getDate.millisecondsSinceEpoch <
            b.getDate.millisecondsSinceEpoch) {
          return 1;
        }
      } else {
        // oldest top
        if (a.getDate.millisecondsSinceEpoch >
            b.getDate.millisecondsSinceEpoch) {
          return 1;
        }
        if (a.getDate.millisecondsSinceEpoch <
            b.getDate.millisecondsSinceEpoch) {
          return -1;
        }
      }
      return 0;
    });
  }
}
