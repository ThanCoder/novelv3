import 'dart:io';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/screens/novel_screens/chapter_text_reader_screen.dart';

class NovelContentReadedBotttom extends StatelessWidget {
  NovelModel novel;
  NovelContentReadedBotttom({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    final file = File('${novel.path}/readed');
    if (!file.existsSync() || file.readAsStringSync().isEmpty) {
      return Container();
    }
    return ElevatedButton(
      onPressed: () {
        try {
          final num = file.readAsStringSync();
          if (int.tryParse(num) == null) {
            CherryToast.error(
              title: Text('"$num" chapter file မရှိပါ'),
              inheritThemeColors: true,
            ).show(context);
            //del
            file.deleteSync();
            return;
          }
          //pass
          //go reader
          currentChapterNotifier.value =
              ChapterModel.fromFile(File('${novel.path}/$num'));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChapterTextReaderScreen(),
            ),
          );
        } catch (e) {
          debugPrint(e.toString());
        }
      },
      child: const Text('ဖတ်ပြီးသား ကနေ'),
    );
  }
}
