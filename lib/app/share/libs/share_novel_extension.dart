import 'package:novel_v3/app/share/libs/share_novel.dart';

extension ShareNovelExtension on List<ShareNovel> {
  void sortAZ({bool isAToZ = true}) {
    sort((a, b) {
      if (isAToZ) {
        return a.title.compareTo(b.title);
      } else {
        return b.title.compareTo(a.title);
      }
    });
  }

  void sortDate({bool isNewest = true}) {
    sort((a, b) {
      if (isNewest) {
        if (a.date.millisecondsSinceEpoch > b.date.millisecondsSinceEpoch) {
          return -1;
        }
        if (a.date.millisecondsSinceEpoch < b.date.millisecondsSinceEpoch) {
          return 1;
        }
      } else {
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

  void sortCompleted({bool isCompleted = true}) {
    sort((a, b) {
      if (isCompleted) {
        if (a.isCompleted && !b.isCompleted) {
          return -1;
        }
        if (!a.isCompleted && b.isCompleted) {
          return 1;
        }
      } else {
        if (a.isCompleted && !b.isCompleted) {
          return 1;
        }
        if (!a.isCompleted && b.isCompleted) {
          return -1;
        }
      }
      return 0;
    });
  }

  void sortAdult({bool isAdult = true}) {
    sort((a, b) {
      if (isAdult) {
        if (a.isAdult && !b.isAdult) {
          return -1;
        }
        if (!a.isAdult && b.isAdult) {
          return 1;
        }
      } else {
        if (a.isAdult && !b.isAdult) {
          return 1;
        }
        if (!a.isAdult && b.isAdult) {
          return -1;
        }
      }
      return 0;
    });
  }
}
