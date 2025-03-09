import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/chapter_book_mark_model.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:provider/provider.dart';

import '../widgets/core/index.dart';

class ChapterBookmarkToggleButton extends StatefulWidget {
  ChapterModel currentChapter;
  ChapterBookmarkToggleButton({super.key, required this.currentChapter});

  @override
  State<ChapterBookmarkToggleButton> createState() =>
      _ChapterBookmarkToggleButtonState();
}

class _ChapterBookmarkToggleButtonState
    extends State<ChapterBookmarkToggleButton> {
  void _toggleBookMark(ChapterModel chapter) async {
    context
        .read<ChapterBookmarkProvider>()
        .toggle(context, bookmark: ChapterBookMarkModel.fromChapter(chapter));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: false,
      future: context.watch<ChapterBookmarkProvider>().exists(
            chapter: widget.currentChapter.title,
          ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 25,
            height: 25,
            child: TLoader(size: 25),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return IconButton(
            onPressed: () => _toggleBookMark(widget.currentChapter),
            color: snapshot.data! ? dangerColor : activeColor,
            icon: Icon(
              snapshot.data! ? Icons.bookmark_remove : Icons.bookmark_add,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
