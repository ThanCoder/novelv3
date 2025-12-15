import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/core/models/chapter_bookmark.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/providers/chapter_bookmark_provider.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/others/chapter_reader/reader_theme.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class ChapterBookmarkAction extends StatefulWidget {
  Chapter chapter;
  String? title;
  ReaderTheme? theme;
  ChapterBookmarkAction({
    super.key,
    required this.chapter,
    this.theme,
    this.title,
  });

  @override
  State<ChapterBookmarkAction> createState() => _ChapterBookmarkActionState();
}

class _ChapterBookmarkActionState extends State<ChapterBookmarkAction> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = false;
  late Novel novel;
  late ChapterBookmarkProvider chapterBookmarkProvider;

  void init() async {
    novel = context.read<NovelProvider>().currentNovel!;
  }

  bool get isExists => context.watch<ChapterBookmarkProvider>().isExistsChapter(
    widget.chapter.number,
  );

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return TLoader(size: 30);
    }
    if (widget.title != null) {
      return Card(
        color: widget.theme?.bgColor.withValues(alpha: 0.7),
        child: Row(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              widget.title!,
              style: TextStyle(color: widget.theme?.fontColor),
            ),
            _getAction(),
          ],
        ),
      );
    }
    return _getAction();
  }

  Widget _getAction() {
    return IconButton(
      color: widget.theme?.bgColor,
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
    if (context.read<ChapterBookmarkProvider>().isExistsChapter(
      widget.chapter.number,
    )) {
      await context.read<ChapterBookmarkProvider>().removeChapter(
        widget.chapter,
      );
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
          await context.read<ChapterBookmarkProvider>().add(
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
