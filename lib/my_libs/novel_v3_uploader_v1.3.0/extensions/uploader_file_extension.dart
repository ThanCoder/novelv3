

import '../models/uploader_file.dart';

extension UploaderFileExtension on List<UploaderFile> {
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