import '../novel_dir_db.dart';

extension ChapterExtension on List<Chapter> {
  void sortNumber({bool isSmallerTop = true}) {
    sort((a, b) {
      if (isSmallerTop) {
        if (a.number > b.number) return 1;
        if (a.number < b.number) return -1;
      } else {
        // biggest top
        if (a.number > b.number) return -1;
        if (a.number < b.number) return 1;
      }
      return 0;
    });
  }
}
