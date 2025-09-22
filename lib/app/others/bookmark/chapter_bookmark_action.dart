import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/bookmark/chapter_bookmark_db.dart';
import 'package:novel_v3/app/others/chapter_reader/reader_theme.dart';
import 'package:novel_v3/app/novel_dir_app.dart';
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

  bool isExists = false;
  bool isLoading = false;

  void init() async {
    try {
      setState(() {
        isLoading = true;
      });
      final novel = context.read<NovelProvider>().getCurrent!;
      final list = await ChapterBookmarkDB.instance(
        novel.getChapterBookmarkPath,
      ).getCacheList(key: novel.title);

      final index = list.indexWhere((e) => e.chapter == widget.chapter.number);
      isExists = index != -1;

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString(), tag: 'ChapterBookmarkAction:init');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

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
      onPressed: _toggleBookmark,
      icon: Icon(
        color: isExists ? Colors.red : Colors.blue,
        isExists ? Icons.bookmark_remove : Icons.bookmark_add,
      ),
    );
  }

  void _toggleBookmark() async {
    final novel = context.read<NovelProvider>().getCurrent!;
    if (isExists) {
      await ChapterBookmarkDB.instance(
        novel.getChapterBookmarkPath,
      ).toggle(chapterNumber: widget.chapter.number, key: novel.title);
      if (!mounted) return;
      setState(() {
        isExists = !isExists;
      });
    } else {
      //add
      showTReanmeDialog(
        context,
        barrierDismissible: false,
        text: widget.chapter.getTitle(),
        title: Text('Book Mark'),
        submitText: 'Add',
        onSubmit: (text) async {
          await ChapterBookmarkDB.instance(novel.getChapterBookmarkPath).toggle(
            chapterNumber: widget.chapter.number,
            title: text,
            key: novel.title,
          );
          if (!mounted) return;
          setState(() {
            isExists = !isExists;
          });
        },
      );
    }
  }
}
