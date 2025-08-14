import 'package:flutter/material.dart';
import 'package:novel_v3/app/providers/novel_provider.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:novel_v3/app/screens/chapter_reader/chapter_reader_screen.dart';
import 'package:novel_v3/app/types/chapter.dart';
import 'package:provider/provider.dart';

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
    final chapterNum = novel.getReadedNumber + 1;
    final path = '${novel.path}/$chapterNum';
    if (!Chapter.isChapterExists(path)) {
      return SizedBox.shrink();
    }

    return TextButton(
      child: Text('Ch: $chapterNum ကနေဖတ်မယ်'),
      onPressed: () {
        goRoute(
          context,
          builder: (context) =>
              ChapterReaderScreen(chapter: Chapter.createPath(path)),
        );
      },
    );
  }
}
