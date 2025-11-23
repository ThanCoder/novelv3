import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:novel_v3/app/others/bookmark/chapter_bookmark_action.dart';
import '../novel_dir_app.dart';

class ChapterListItem extends StatelessWidget {
  final Chapter chapter;
  final void Function(Chapter chapter) onClicked;
  final void Function(Chapter chapter)? onRightClicked;
  final void Function(bool? isChecked)? onCheckChanged;
  final bool? isChecked;
  const ChapterListItem({
    super.key,
    required this.chapter,
    required this.onClicked,
    this.onRightClicked,
    this.isChecked,
    this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        spacing: 5,
        children: [
          isChecked == null
              ? SizedBox.shrink()
              : Checkbox(value: isChecked, onChanged: onCheckChanged),
          Expanded(child: _getItem()),
          ChapterBookmarkAction(chapter: chapter),
        ],
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 400),
      duration: Duration(milliseconds: 500),
    );
  }

  Widget _getItem() {
    return GestureDetector(
      onTap: () => onClicked(chapter),
      onSecondaryTap: () {
        if (onRightClicked == null) return;
        onRightClicked!(chapter);
      },
      onLongPress: () {
        if (onRightClicked == null) return;
        onRightClicked!(chapter);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          children: [
            Text('Ch: ${chapter.number}'),
            Expanded(
              child: Text(
                chapter.getTitle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
