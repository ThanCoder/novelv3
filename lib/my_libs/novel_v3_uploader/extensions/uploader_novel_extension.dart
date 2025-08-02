import '../models/uploader_novel.dart';

extension UploaderNovelExtension on List<UploaderNovel> {
  void sortDate({bool isNewestOrOld = true}) {
    sort((a, b) {
      // နောက်ဆုံး date
      if (isNewestOrOld) {
        if (a.date.millisecondsSinceEpoch > b.date.millisecondsSinceEpoch) {
          return -1;
        }
        if (a.date.millisecondsSinceEpoch < b.date.millisecondsSinceEpoch) {
          return 1;
        }
      } else {
        //အဟောင်းကို ထိပ်တင်မယ်
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
