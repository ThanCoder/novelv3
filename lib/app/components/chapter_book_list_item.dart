import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/chapter_bookmark_model.dart';

class ChapterBookListItem extends StatelessWidget {
  ChapterBookmarkModel book;
  void Function(ChapterBookmarkModel book) onClicked;
  void Function(ChapterBookmarkModel book)? onLongClicked;
  ChapterBookListItem({
    super.key,
    required this.book,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(book),
      onLongPress: () {
        if (onLongClicked != null) {
          onLongClicked!(book);
        }
      },
      onSecondaryTap: () {
        if (onLongClicked != null) {
          onLongClicked!(book);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            spacing: 7,
            children: [
              Text(book.chapter.toString()),
              Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
