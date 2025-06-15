import 'package:novel_v3/app/models/novel_model.dart';

extension NovelExtension on List<NovelModel> {
  void sortTitle(bool isAsc) {
    sort((a, b) => isAsc
            ? a.title.compareTo(b.title) // Ascending
            : b.title.compareTo(a.title) // Descending
        );
  }

  void sortDate(bool isAsc) {
    sort((a, b) {
      if (isAsc) {
        if (a.date > b.date) return 1;
        if (a.date < b.date) return -1;
      } else {
        if (a.date > b.date) return -1;
        if (a.date < b.date) return 1;
      }

      return 0;
    });
  }

  void sortCompleted(bool isAsc) {
    sort((a, b) {
      if (isAsc) {
        if (a.isCompleted && !b.isCompleted) return -1;
        if (!a.isCompleted && b.isCompleted) return 1;
      } else {
        if (a.isCompleted && !b.isCompleted) return 1;
        if (!a.isCompleted && b.isCompleted) return -1;
      }

      return 0;
    });
  }

  void sortAdult(bool isAsc) {
    sort((a, b) {
      if (isAsc) {
        if (a.isAdult && !b.isAdult) return -1;
        if (!a.isAdult && b.isAdult) return 1;
      } else {
        if (a.isAdult && !b.isAdult) return 1;
        if (!a.isAdult && b.isAdult) return -1;
      }

      return 0;
    });
  }
}
