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
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 3,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 200,
                      child: TCacheImage(
                        url: novel.coverUrl,
                        // cachePath: PathUtil.getCachePath(),
                      ),
                    ),
                    SelectableText(novel.title, maxLines: null),
                    Text('Author: ${novel.author}'),
                    Text('ဘာသာပြန်: ${novel.translator}'),
                    Text('MC: ${novel.mc}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
            ),
            TTagsWrapView(values: novel.getTags),
            SelectableText(novel.desc, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
