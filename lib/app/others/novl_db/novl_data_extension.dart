import 'package:novel_v3/app/others/novl_db/novl_data.dart';

extension NovlDataExtension on List<NovlData> {
  void sortTitle({bool aToZ = true}) {
    sort((a, b) {
      if (aToZ) {
        // a -z
        return a.novelMeta.title.compareTo(b.novelMeta.title);
      } else {
        // z - a
        return b.novelMeta.title.compareTo(a.novelMeta.title);
      }
    });
  }

  void sortSize({bool isSmallest = true}) {
    sort((a, b) {
      if (isSmallest) {
        if (a.size > b.size) return 1;
        if (a.size < b.size) return -1;
      } else {
        if (a.size > b.size) return -1;
        if (a.size < b.size) return 1;
      }
      return 0;
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
}
