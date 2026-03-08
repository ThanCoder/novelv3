import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/chapter_bookmark.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/other_apps/chapter_reader/reader_theme.dart';
import 'package:t_widgets/t_widgets.dart';

class ChapterBookmarkAction extends StatefulWidget {
  final Chapter chapter;
  final String? title;
  final ReaderTheme? theme;
  final Novel currentNovel;
  final bool Function(int chpaterNumber) isExistsChapter;
  final Future<void> Function(int chpaterNumber) onRemoveChapter;
  final Future<void> Function(ChapterBookmark bookmark) onAddChapterBookmark;
  const ChapterBookmarkAction({
    super.key,
    required this.currentNovel,
    required this.chapter,
    required this.isExistsChapter,
    required this.onRemoveChapter,
    required this.onAddChapterBookmark,
    this.theme,
    this.title,
  });

  @override
  State<ChapterBookmarkAction> createState() => _ChapterBookmarkActionState();
}

class _ChapterBookmarkActionState extends State<ChapterBookmarkAction> {
  bool isLoading = false;

  bool get isExists => widget.isExistsChapter(widget.chapter.number);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return TLoader(size: 30);
    }
    if (widget.title != null) {
      return Card(
        child: Row(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Text(widget.title!), _getAction()],
        ),
      );
    }
    return _getAction();
  }

  Widget _getAction() {
    return IconButton(
      // color: widget.theme?.bgColor,
      onPressed: _toggle,

      icon: Icon(
        color: isExists ? Colors.red : Colors.blue,
        isExists ? Icons.bookmark_remove : Icons.bookmark_add,
      ),
    );
  }

  void _toggle() async {
    setState(() {
      isLoading = true;
    });
    if (widget.isExistsChapter(widget.chapter.number)) {
      await widget.onRemoveChapter(widget.chapter.number);
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } else {
      showTReanmeDialog(
        context,
        barrierDismissible: false,
        text: widget.chapter.title,
        title: Text('BookMark'),
        submitText: 'Rename',
        onCancel: () {
          if (!mounted) return;
          setState(() {
            isLoading = false;
          });
        },
        onSubmit: (text) async {
          await widget.onAddChapterBookmark(
            ChapterBookmark(title: text, chapter: widget.chapter.number),
          );
          if (!mounted) return;
          setState(() {
            isLoading = false;
          });
        },
      );
    }
  }
}
