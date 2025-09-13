import 'package:novel_v3/app/others/share/libs/share_dir_file.dart';

extension ShareDirFileExtension on List<ShareDirFile> {
  void sortAZ({bool isAToZ = true}) {
    sort((a, b) {
      if (isAToZ) {
        return a.name.compareTo(b.name);
      } else {
        return b.name.compareTo(a.name);
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

  void sortPdf({bool isPDF = true}) {
    sort((a, b) {
      if (isPDF) {
        if (a.mime.endsWith('/pdf') && !b.mime.endsWith('/pdf')) {
          return -1;
        }
        if (!a.mime.endsWith('/pdf') && b.mime.endsWith('/pdf')) {
          return 1;
        }
      } else {
        if (a.mime.endsWith('/pdf') && !b.mime.endsWith('/pdf')) {
          return 1;
        }
        if (!a.mime.endsWith('/pdf') && b.mime.endsWith('/pdf')) {
          return -1;
        }
      }
      return 0;
    });
  }

  void sortChapter({bool isChapter = true}) {
    sort((a, b) {
      if (isChapter) {
        if (a.isChapterFile && !b.isChapterFile) {
          return -1;
        }
        if (!a.isChapterFile && b.isChapterFile) {
          return 1;
        }
      } else {
        if (a.isChapterFile && !b.isChapterFile) {
          return 1;
        }
        if (!a.isChapterFile && b.isChapterFile) {
          return -1;
        }
      }
      return 0;
    });
  }

  void sortConfigFile({bool isConfigFile = true}) {
    sort((a, b) {
      if (isConfigFile) {
        if (a.isConfigFile && !b.isConfigFile) {
          return -1;
        }
        if (!a.isConfigFile && b.isConfigFile) {
          return 1;
        }
      } else {
        if (a.isConfigFile && !b.isConfigFile) {
          return 1;
        }
        if (!a.isConfigFile && b.isConfigFile) {
          return -1;
        }
      }
      return 0;
    });
  }
}
