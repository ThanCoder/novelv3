import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/core/providers/chapter_provider.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/content/chapter_bookmark_page/chapter_bookmark_toggle_button.dart';
import 'package:novel_v3/app/ui/forms/edit_chapter_screen.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ChapterListItem extends StatefulWidget {
  final Chapter chapter;
  final void Function(Chapter chapter)? onClicked;
  final void Function(Chapter chapter)? onRightClicked;
  final void Function(Chapter chapter)? onCheckedChanged;
  final void Function()? toggleMultiCheckBox;
  final void Function()? onDeleteMultiChapterClicked;
  final bool? isChecked;
  const ChapterListItem({
    super.key,
    required this.chapter,
    this.onClicked,
    this.onRightClicked,
    this.isChecked,
    this.onCheckedChanged,
    this.toggleMultiCheckBox,
    this.onDeleteMultiChapterClicked,
  });

  @override
  State<ChapterListItem> createState() => _ChapterListItemState();
}

class _ChapterListItemState extends State<ChapterListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: widget.isChecked != null
            ? _getCheckBox()
            : Icon(Icons.article),
        title: GestureDetector(
          onSecondaryTap: () => _showItemMenu(widget.chapter),
          child: Text(
            '${widget.chapter.number}: ${widget.chapter.title}',
            maxLines: 1,
          ),
        ),
        trailing: ChapterBookmarkToggleButton(chatper: widget.chapter),
        onTap: () {
          if (widget.isChecked != null) {
            _toggleCheck();
            return;
          }
          widget.onClicked?.call(widget.chapter);
        },
        onLongPress: () => _showItemMenu(widget.chapter),
      ),
    );
  }

  Widget _getCheckBox() {
    return Checkbox.adaptive(
      value: widget.isChecked,
      onChanged: (value) => _toggleCheck(),
    );
  }

  void _toggleCheck() {
    widget.onCheckedChanged?.call(widget.chapter);
  }

  void _showItemMenu(Chapter chapter) {
    showTMenuBottomSheet(
      context,
      children: [
        widget.isChecked != null
            ? SizedBox.shrink()
            : ListTile(
                leading: Icon(Icons.edit_document),
                title: Text('Edit'),
                onTap: () {
                  closeContext(context);
                  _goEditPage(chapter);
                },
              ),
        widget.isChecked != null
            ? SizedBox.shrink()
            : ListTile(
                leading: Icon(Icons.copy_all),
                title: Text('Copy Content Text'),
                onTap: () async {
                  closeContext(context);
                  final content = await context
                      .read<ChapterProvider>()
                      .getContent(chapter.number);
                  if (content == null || content.isEmpty) return;
                  ThanPkg.appUtil.copyText(content);
                },
              ),
        ListTile(
          leading: Icon(
            widget.isChecked == null
                ? Icons.check_box
                : Icons.check_box_outline_blank,
          ),
          title: Text(
            '${widget.isChecked == null ? 'Show' : 'Hide'} Multi CheckBox',
          ),
          onTap: () {
            closeContext(context);
            widget.toggleMultiCheckBox?.call();
          },
        ),
        _getDeleteWidget(chapter),
      ],
    );
  }

  Widget _getDeleteWidget(Chapter chapter) {
    if (widget.isChecked != null) {
      return ListTile(
        leading: Icon(Icons.delete_forever, color: Colors.red),
        title: Text('Delete Multi Forever'),
        onTap: () {
          closeContext(context);
          widget.onDeleteMultiChapterClicked?.call();
        },
      );
    }
    return ListTile(
      leading: Icon(Icons.delete_forever, color: Colors.red),
      title: Text('Delete Forever'),
      onTap: () {
        closeContext(context);
        _deleteConfirm(chapter);
      },
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
      barrierDismissible: false,
      onSubmit: () {
        context.read<ChapterProvider>().delete(chapter);
      },
    );
  }
}
