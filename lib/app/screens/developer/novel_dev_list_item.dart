import 'package:flutter/material.dart';
import 'package:novel_v3/app/types/novel.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';

typedef NovelDevListItemOnClickCallback = void Function(Novel novel);
typedef NovelDevListItemOnExistsTitle = bool Function(Novel novel);

class NovelDevListItem extends StatelessWidget {
  Novel novel;
  NovelDevListItemOnClickCallback onClicked;
  NovelDevListItemOnClickCallback? onRightClicked;
  NovelDevListItemOnExistsTitle? onExistsTitle;
  NovelDevListItem({
    super.key,
    required this.novel,
    required this.onClicked,
    this.onRightClicked,
    this.onExistsTitle,
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
                    Text('Size: ${novel.getSize}'),
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
                    // already title
                    Text(
                      isExistsTitle
                          ? 'Online မှာနေပါတယ်'
                          : 'Online မှာမရှိပါ...',
                      style: TextStyle(
                        color: isExistsTitle ? Colors.green : Colors.red,
                      ),
                    ),
                    _getTagWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTagWidget() {
    return TTagsWrapView(values: novel.getTags, type: TTagsTypes.text);
  }

  bool get isExistsTitle {
    if (onExistsTitle != null) {
      return onExistsTitle!(novel);
    }
    return false;
  }
}
