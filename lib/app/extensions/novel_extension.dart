import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:novel_v3/app/types/novel.dart';

extension NovelExtension on List<Novel> {
  Future<void> initCalcSize() async {
    for (var novel in this) {
      novel.cacheSize = await compute(_calcSize, novel.path);
    }
  }

  void sortDesc({bool isAdded = true}) {
    sort((a, b) {
      if (isAdded) {
        return a.getContent.isNotEmpty ? -1 : 1;
      } else {
        return a.getContent.isNotEmpty ? 1 : -1;
      }
    });
  }

  void sortCompleted({bool isCompleted = true}) {
    sort((a, b) {
      if (isCompleted) {
        return a.isCompleted ? -1 : 1;
      } else {
        return a.isCompleted ? 1 : -1;
      }
    });
  }

  void sortAdult({bool isAdult = true}) {
    sort((a, b) {
      if (isAdult) {
        return a.isAdult ? -1 : 1;
      } else {
        return a.isAdult ? 1 : -1;
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

int _calcSize(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) return 0;
  int size = 0;
  for (var file in dir.listSync(followLinks: false)) {
    if (file is File) {
      size += file.lengthSync();
    }
  }
  return size;
}
