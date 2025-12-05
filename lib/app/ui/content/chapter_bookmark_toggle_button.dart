import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/core/models/chapter_bookmark.dart';
import 'package:novel_v3/app/core/providers/chapter_bookmark_provider.dart';
import 'package:provider/provider.dart';

class ChapterBookmarkToggleButton extends StatefulWidget {
  final Chapter chatper;
  const ChapterBookmarkToggleButton({super.key, required this.chatper});

  @override
  State<ChapterBookmarkToggleButton> createState() =>
      _ChapterBookmarkToggleButtonState();
}

class _ChapterBookmarkToggleButtonState
    extends State<ChapterBookmarkToggleButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: toggle,
      icon: isExists
          ? Icon(Icons.bookmark_remove, color: Colors.red)
          : Icon(Icons.bookmark_add, color: Colors.blue),
    );
  }

  bool get isExists => context.watch<ChapterBookmarkProvider>().isExistsChapter(
    widget.chatper.number,
  );

  void toggle() {
    final provider = context.read<ChapterBookmarkProvider>();
    if (provider.isExistsChapter(widget.chatper.number)) {
      provider.removeChapter(widget.chatper);
    } else {
      provider.add(
        ChapterBookmark(
          title: widget.chatper.title,
          chapter: widget.chatper.number,
        ),
      );
    }
  }
}
