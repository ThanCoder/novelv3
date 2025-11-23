import 'package:novel_v3/app/core/models/novel.dart';

extension NovelExtension on List<Novel> {
  void sortN3Data({bool isExported = true}) {
    sort((a, b) {
      // if (isExported) {
      //   //ထုတ်ပြီးသား
      //   if (a.isExistsNovelData() && !b.isExistsNovelData()) return -1;
      //   if (!a.isExistsNovelData() && b.isExistsNovelData()) return 1;
      // } else {
      //   //မထုတ်ရသေး
      //   if (a.isExistsNovelData() && !b.isExistsNovelData()) return 1;
      //   if (!a.isExistsNovelData() && b.isExistsNovelData()) return -1;
      // }
      return 0;
    });
  }

  void sortDesc({bool isAdded = true}) {
    sort((a, b) {
      if (isAdded) {
        //ထုတ်ပြီးသား
        if (a.isExistsDesc && !b.isExistsDesc) return -1;
        if (!a.isExistsDesc && b.isExistsDesc) return 1;
      } else {
        //မထုတ်ရသေး
        if (a.isExistsDesc && !b.isExistsDesc) return 1;
        if (!a.isExistsDesc && b.isExistsDesc) return -1;
      }
      return 0;
    });
  }

  void sortCompleted({bool isCompleted = true}) {
    sort((a, b) {
      if (isCompleted) {
        return a.meta.isCompleted ? -1 : 1;
      } else {
        return a.meta.isCompleted ? 1 : -1;
      }
    });
  }

  void sortAdult({bool isAdult = true}) {
    sort((a, b) {
      if (isAdult) {
        return a.meta.isAdult ? -1 : 1;
      } else {
        return a.meta.isAdult ? 1 : -1;
      }
    });
  }

  void sortSize({bool isSmallest = true}) {
    sort((a, b) {
      if (isSmallest) {
        // isSmallest
        if (a.getSizeInt > b.getSizeInt) {
          return 1;
        }
        if (a.getSizeInt < b.getSizeInt) {
          return -1;
        }
      } else {
        // is largest

        if (a.getSizeInt > b.getSizeInt) {
          return -1;
        }
        if (a.getSizeInt < b.getSizeInt) {
          return 1;
        }
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
}
