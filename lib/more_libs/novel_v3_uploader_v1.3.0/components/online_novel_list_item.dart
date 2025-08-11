import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/extensions/datetime_extension.dart';

import '../novel_v3_uploader.dart';

class OnlineNovelListItem extends StatelessWidget {
  UploaderNovel novel;
  void Function(UploaderNovel novel) onClicked;
  OnlineNovelListItem({
    super.key,
    required this.novel,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(novel),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                SizedBox(
                  width: 140,
                  height: 160,
                  child: TCacheImage(
                    url: novel.coverUrl,
                    cachePath: NovelV3Uploader.instance.imageCachePath,
                  ),
                ),
                Expanded(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Text(novel.title),
                      Text('Author: ${novel.author}'),
                      Text('ဘာသာပြန်: ${novel.translator}'),
                      Text('MC: ${novel.mc}'),
                      TTagsWrapView(values: novel.getTags),
                      Wrap(
                        spacing: 5,
                        children: [
                          StatusText(
                            bgColor: novel.isCompleted
                                ? StatusText.completedColor
                                : StatusText.onGoingColor,
                            text: novel.isCompleted ? 'Completed' : 'OnGoing',
                          ),
                          novel.isAdult
                              ? StatusText(
                                  text: 'Adult',
                                  bgColor: StatusText.adultColor,
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      Text('ရက်စွဲ: ${novel.date.toParseTime()}'),
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
