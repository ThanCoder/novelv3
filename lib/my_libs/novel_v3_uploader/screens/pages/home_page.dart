import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../components/status_text.dart';
import '../../models/uploader_novel.dart';

class HomePage extends StatelessWidget {
  UploaderNovel novel;
  HomePage({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              child: Row(
                // crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 180,
                      height: 220,
                      child: TCacheImage(
                        url: novel.coverUrl,
                        // cachePath: PathUtil.getCachePath(),
                      ),
                    ),
                  ),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      SelectableText(novel.title, maxLines: null),
                      Text('Author: ${novel.author}'),
                      Text('ဘာသာပြန်: ${novel.translator}'),
                      Text('MC: ${novel.mc}'),
                      Row(
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

                      // TChip(
                      //   title: Text(
                      //     novel.isCompleted ? 'isCompleted' : 'OnGoing',
                      //     style: TextStyle(
                      //       color: novel.isCompleted
                      //           ? Colors.teal
                      //           : Colors.grey,
                      //     ),
                      //   ),
                      // ),
                      // novel.isAdult
                      //     ? TChip(
                      //         title: const Text(
                      //           'isAdult',
                      //           style: TextStyle(color: Colors.red),
                      //         ),
                      //       )
                      //     : const SizedBox.shrink(),

                      Text('ရက်စွဲ: ${novel.date.toParseTime()}'),
                    ],
                  ),
                ],
              ),
            ),
            TTagsWrapView(values: novel.getTags),
            SelectableText(novel.desc, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
