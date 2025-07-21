import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelListItem extends StatelessWidget {
  NovelModel novel;
  void Function(NovelModel novel) onClicked;
  void Function(NovelModel novel)? onLongClicked;
  NovelListItem({
    super.key,
    required this.novel,
    required this.onClicked,
    this.onLongClicked,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onClicked(novel),
        onLongPress: () {
          if (onLongClicked == null) return;
          onLongClicked!(novel);
        },
        onSecondaryTap: () {
          if (onLongClicked == null) return;
          onLongClicked!(novel);
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 8,
              children: [
                TImageFile(
                  width: 130,
                  height: 150,
                  path: novel.coverPath,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        novel.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('ရေးသားသူ: ${novel.author}'),
                      Text('MC: ${novel.mc}'),
                      Text('Completed: ${novel.isCompleted.toString()}'),
                      Text('Adult: ${novel.isAdult.toString()}'),
                      Text('Date: ${novel.getDate.toParseTime()}'),
                      Text('Size: ${novel.getSize.toFileSizeLabel()}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
