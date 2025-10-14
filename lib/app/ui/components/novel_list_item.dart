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
          child: Row(
            spacing: 5,
            children: [
              SizedBox(
                width: 100,
                height: 130,
                child: TImage(source: novel.getCoverPath),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 2,
                  children: [
                    _getRowTile(
                      iconData: Icons.title,
                      text: novel.title,
                      fontWeight: FontWeight.bold,
                    ),
                    _getRowTile(
                      text: 'Author: ${novel.getAuthor}',
                      iconData: Icons.edit,
                    ),
                    _getRowTile(
                      text: novel.getTranslator,
                      iconData: Icons.translate,
                    ),
                    _getRowTile(text: novel.getMC, iconData: Icons.person),
                    _getRowTile(
                      iconData: Icons.date_range,
                      text: novel.date.toParseTime(),
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

  Widget _getRowTile({
    IconData? iconData,
    required String text,
    FontWeight? fontWeight,
  }) {
    return Row(
      children: [
        iconData == null ? SizedBox.fromSize() : Icon(iconData),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, fontWeight: fontWeight),
          ),
        ),
      ],
    );
  }
}
