import 'package:flutter/material.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';
import '../novel_dir_app.dart';

class NovelListItem extends StatelessWidget {
  Novel novel;
  void Function(Novel novel)? onClicked;
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
      onTap: () => onClicked?.call(novel),
      onSecondaryTap: () => onRightClicked?.call(novel),
      onLongPress: () => onRightClicked?.call(novel),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              SizedBox(
                width: 140,
                height: 150,
                child: TImage(source: novel.getCoverPath),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 2,
                children: [
                  Text(
                    'T: ${novel.title}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13),
                  ),
                  Text('Author: ${novel.getAuthor}'),
                  Text('Translator: ${novel.getTranslator}'),
                  Text('MC: ${novel.getMC}'),
                  Text(
                    'Date: ${novel.date.toParseTime()}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
