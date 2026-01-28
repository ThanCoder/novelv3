import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/chapter_bookmark.dart';
import 'package:novel_v3/app/core/providers/chapter_bookmark_provider.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class ChapterBookmarkListItem extends StatefulWidget {
  final ChapterBookmark bookmark;
  final void Function(ChapterBookmark bookmark)? onClicked;
  final void Function(ChapterBookmark bookmark)? onRightClicked;
  const ChapterBookmarkListItem({
    super.key,
    required this.bookmark,
    this.onClicked,
    this.onRightClicked,
  });

  @override
  State<ChapterBookmarkListItem> createState() => _ChapterListItemState();
}

class _ChapterListItemState extends State<ChapterBookmarkListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        // leading: Icon(Icons.article),
        title: Text(
          '${widget.bookmark.chapter}: ${widget.bookmark.title}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          onPressed: _removeBookmark,
          icon: Icon(Icons.bookmark_remove, color: Colors.red),
        ),
        onTap: () => widget.onClicked?.call(widget.bookmark),
        onLongPress: () => _showItemMenu(widget.bookmark),
      ),
    );
  }

  void _showItemMenu(ChapterBookmark chapter) {
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
      ],
    );
  }

  void _goEditPage(ChapterBookmark chapter) {
    showTReanmeDialog(
      context,
      text: chapter.title,
      title: Text('BookMark'),
      submitText: 'Rename',
      onSubmit: (text) {
        context.read<ChapterBookmarkProvider>().update(
          widget.bookmark.copyWith(title: text),
        );
      },
    );
  }

  void _removeBookmark() {
    final proiver = context.read<ChapterBookmarkProvider>();
    proiver.remove(widget.bookmark);
  }
}
