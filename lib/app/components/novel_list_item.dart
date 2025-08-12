import 'package:flutter/material.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';
import '../novel_dir_app.dart';

class NovelListItem extends StatelessWidget {
  Novel novel;
  void Function(Novel novel) onClicked;
  void Function(Novel novel)? onRightClicked;
  NovelListItem({
    super.key,
    required this.novel,
    required this.onClicked,
    this.onRightClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(novel),
      onSecondaryTap: () {
        if (onRightClicked == null) return;
        onRightClicked!(novel);
      },
      onLongPress: () => onRightClicked?.call(novel),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          child: Row(
            spacing: 8,
            children: [
              SizedBox(
                width: 140,
                height: 150,
                child: TImage(source: novel.getCoverPath),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      'T: ${novel.title}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13),
                    ),
                    // Text('Size: ${novel.getSize}'),
                    Row(
                      children: [
                        Icon(Icons.date_range),
                        Text(
                          novel.date.toParseTime(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
