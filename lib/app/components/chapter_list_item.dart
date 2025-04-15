import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/index.dart';

class ChapterListItem extends StatelessWidget {
  ChapterModel chapter;
  void Function(ChapterModel chapter) onClicked;
  void Function(ChapterModel chapter)? onLongClicked;
  ChapterListItem({
    super.key,
    required this.chapter,
    required this.onClicked,
    this.onLongClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(chapter),
      onLongPress: () {
        if (onLongClicked != null) {
          onLongClicked!(chapter);
        }
      },
      onSecondaryTap: () {
        if (onLongClicked != null) {
          onLongClicked!(chapter);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            spacing: 7,
            children: [
              Text(chapter.number.toString()),
              Expanded(
                child: Text(
                  chapter.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
