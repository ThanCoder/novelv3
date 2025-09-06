import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:novel_v3/app/bookmark/chapter_bookmark_action.dart';
import '../novel_dir_app.dart';

class ChapterListItem extends StatelessWidget {
  Chapter chapter;
  void Function(Chapter chapter) onClicked;
  void Function(Chapter chapter)? onRightClicked;
  ChapterListItem({
    super.key,
    required this.chapter,
    required this.onClicked,
    this.onRightClicked,
  });

  @override
  Widget build(BuildContext context) {
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
        child:
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                spacing: 5,
                children: [
                  Text('Ch: ${chapter.number}'),
                  Expanded(
                    child: Text(
                      chapter.getTitle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ChapterBookmarkAction(chapter: chapter),
                ],
              ),
            ).animate().fadeIn(
              delay: Duration(milliseconds: 400),
              duration: Duration(milliseconds: 500),
            ),
      ),
    );
  }
}
