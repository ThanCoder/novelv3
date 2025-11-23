import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../ui/components/status_text.dart';

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
        child:
            Card(
              child: Row(
                spacing: 8,
                children: [
                  SizedBox(
                    width: 90,
                    height: 120,
                    child: TImage(source: novel.getCoverPath),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        _getRowTile(
                          text: novel.title,
                          iconData: Icons.title,
                          fontWeight: FontWeight.bold,
                        ),
                        FutureBuilder(
                          future: novel.getAllSizeLabel(),
                          builder: (context, asyncSnapshot) {
                            if (asyncSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('Size: တွက်ချက်နေပါတယ်...');
                            }
                            if (asyncSnapshot.hasData) {
                              return _getRowTile(
                                text: asyncSnapshot.data ?? '',
                                iconData: Icons.sd_storage,
                              );
                            }
                            return SizedBox.shrink();
                          },
                        ),
                        // date
                        _getRowTile(
                          text: novel.date.toParseTime(),
                          iconData: Icons.date_range,
                        ),

                        // status
                        _getStatusWidget(),
                        // already title
                        Text(
                          isExistsTitle
                              ? 'Online မှာရှိနေပါတယ်'
                              : 'Online မှာမရှိပါ...',
                          style: TextStyle(
                            color: isExistsTitle ? Colors.green : Colors.red,
                          ),
                        ),
                        // _getTagWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().shimmer(
              delay: Duration(milliseconds: 400),
              duration: Duration(milliseconds: 900),
            ),
      ),
    );
  }

  Widget _getRowTile({
    required IconData iconData,
    required String text,
    FontWeight? fontWeight,
  }) {
    return Row(
      children: [
        Icon(iconData),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, fontWeight: fontWeight),
          ),
        ),
      ],
    );
  }

  Widget _getStatusWidget() {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        StatusText(
          bgColor: novel.meta.isCompleted
              ? StatusText.completedColor
              : StatusText.onGoingColor,
          text: novel.meta.isCompleted ? 'Completed' : 'OnGoing',
        ),
        novel.meta.isAdult
            ? StatusText(bgColor: StatusText.adultColor, text: 'Adult')
            : SizedBox.shrink(),
        !novel.isExistsDesc
            ? StatusText(
                bgColor: const Color.fromARGB(255, 102, 87, 22),
                text: 'Description မရှိပါ',
              )
            : StatusText(
                bgColor: const Color.fromARGB(255, 2, 73, 2),
                text: 'Description ရှိ',
              ),
        // is novel data is exists
        novel.isExistsNovelData()
            ? StatusText(text: 'V3Data ထုတ်ထားပါတယ်')
            : SizedBox.shrink(),
      ],
    );
  }

  bool get isExistsTitle {
    if (onExistsTitle != null) {
      return onExistsTitle!(novel);
    }
    return false;
  }
}
