import 'package:flutter/material.dart';
import 'package:novel_v3/app/novel_dir_app.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:novel_v3/app/screens/chapter_reader/chapter_reader_screen.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class ReadedRecentButton extends StatefulWidget {
  const ReadedRecentButton({super.key});

  @override
  State<ReadedRecentButton> createState() => _ReadedRecentButtonState();
}

class _ReadedRecentButtonState extends State<ReadedRecentButton> {
  @override
  Widget build(BuildContext context) {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) {
      return SizedBox.shrink();
    }
    final chapterNum = novel.getReadedNumber;
    final path = '${novel.path}/$chapterNum';
    if (!Chapter.isChapterExists(path)) {
      return SizedBox.shrink();
    }

    return TextButton(
      child: Text('Ch: $chapterNum ကနေဖတ်မယ်'),
      onPressed: () {
        goRoute(
          context,
          builder: (context) => ChapterReaderScreen(
            chapter: Chapter.createPath(path),
            onReaderClosed: _checkLastChapter,
          ),
        );
      },
    );
  }

  void _checkLastChapter(Chapter chapter) {
    try {
      final novel = context.read<NovelProvider>().getCurrent;
      if (novel == null) return;
      final readed = novel.getReadedNumber;
      if (chapter.number <= readed) return;
      //ကြီးနေတယ်ဆိုရင်
      showTConfirmDialog(
        context,
        barrierDismissible: false,
        title: 'Readed ကိုသိမ်းဆည်းချင်ပါသလား?',
        contentText:
            'သိမ်းဆည်းထားသော Chapter:`$readed`\nဖတ်ပြီးသွားတဲ့ Chapter:`${chapter.number}`',
        submitText: 'သိမ်းမယ်',
        cancelText: 'မသိမ်းဘူး',
        onSubmit: () {
          novel.setReaded(chapter.number.toString());
          context.read<NovelProvider>().refreshNotifier();
          setState(() {});
        },
      );
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString());
    }
  }
}
