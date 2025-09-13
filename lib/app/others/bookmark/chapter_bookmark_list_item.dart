import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:novel_v3/app/others/bookmark/chapter_bookmark_data.dart';

class ChapterBookmarkListItem extends StatelessWidget {
  ChapterBookmarkData bookmark;
  void Function(ChapterBookmarkData bookmark) onClicked;
  void Function(ChapterBookmarkData bookmark)? onRightClicked;
  ChapterBookmarkListItem({
    super.key,
    required this.bookmark,
    required this.onClicked,
    this.onRightClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(bookmark),
      onSecondaryTap: () {
        if (onRightClicked == null) return;
        onRightClicked!(bookmark);
      },
      onLongPress: () {
        if (onRightClicked == null) return;
        onRightClicked!(bookmark);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child:
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                spacing: 5,
                children: [
                  Text('Ch: ${bookmark.chapter}'),
                  Expanded(
                    child: Text(
                      bookmark.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
