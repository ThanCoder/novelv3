import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/core/providers/chapter_provider.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/content/chapter_bookmark_toggle_button.dart';
import 'package:novel_v3/app/ui/forms/edit_chapter_screen.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class ChapterListItem extends StatefulWidget {
  final Chapter chapter;
  final void Function(Chapter chapter)? onClicked;
  final void Function(Chapter chapter)? onRightClicked;
  const ChapterListItem({
    super.key,
    required this.chapter,
    this.onClicked,
    this.onRightClicked,
  });

  @override
  State<ChapterListItem> createState() => _ChapterListItemState();
}

class _ChapterListItemState extends State<ChapterListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.article),
        title: Text(
          '${widget.chapter.number}: ${widget.chapter.title}',
          maxLines: 1,
        ),
        trailing: ChapterBookmarkToggleButton(chatper: widget.chapter),
        onTap: () => widget.onClicked?.call(widget.chapter),
        onLongPress: () => _showItemMenu(widget.chapter),
      ),
    );
  }

  void _showItemMenu(Chapter chapter) {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.edit_document),
          title: Text('Edit'),
          onTap: () {
            closeContext(context);
            _goEditPage(chapter);
          },
        ),
        ListTile(
          leading: Icon(Icons.delete_forever),
          title: Text('Delete Forever'),
          onTap: () {
            closeContext(context);
            _deleteConfirm(chapter);
          },
        ),
      ],
    );
  }

  void _goEditPage(Chapter chapter) {
    final novelPath = context.read<NovelProvider>().currentNovel!.path;
    goRoute(
      context,
      builder: (context) =>
          EditChapterScreen(novelPath: novelPath, chapter: chapter),
    );
  }

  void _deleteConfirm(Chapter chapter) {
    showTConfirmDialog(
      context,
      contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
      submitText: 'Delete Forever',
      onSubmit: () {
        context.read<ChapterProvider>().delete(chapter);
      },
    );
  }
}
