import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/status_text.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/setting/app_notifier.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelDataListItem extends StatelessWidget {
  NovelDataModel novelData;
  void Function(NovelDataModel novelData) onClicked;
  void Function(NovelDataModel novelData)? onLongClicked;
  bool Function(NovelDataModel novelData)? isAlreadyInstalled;
  bool isShowPathLabel;
  NovelDataListItem({
    super.key,
    required this.novelData,
    required this.onClicked,
    this.onLongClicked,
    this.isShowPathLabel = false,
    this.isAlreadyInstalled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(novelData),
      onLongPress: () {
        if (onLongClicked != null) {
          onLongClicked!(novelData);
        }
      },
      onSecondaryTap: () {
        if (onLongClicked != null) {
          onLongClicked!(novelData);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 7,
              children: [
                SizedBox(
                  width: 130,
                  height: 140,
                  child: Container(
                    color:
                        isDarkThemeNotifier.value ? Colors.white : Colors.black,
                    child: TImageFile(path: novelData.coverPath),
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: 2,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        novelData.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                          'Size: ${novelData.size.toDouble().toFileSizeLabel()}'),
                      // status
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          StatusText(
                            bgColor: novelData.isCompleted
                                ? StatusText.completedColor
                                : StatusText.onGoingColor,
                            text:
                                novelData.isCompleted ? 'Completed' : 'OnGoing',
                          ),
                          novelData.isAdult
                              ? StatusText(
                                  text: 'Adult',
                                  bgColor: StatusText.adultColor,
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),

                      isShowPathLabel
                          ? Text(
                              'Path: ${novelData.path}',
                              style: const TextStyle(fontSize: 12),
                            )
                          : const SizedBox.shrink(),
                      isAlreadyInstalled == null
                          ? const SizedBox.shrink()
                          : Text(
                              isAlreadyInstalled!(novelData)
                                  ? 'ရှိနေပြီးသားပါ'
                                  : 'မသွင်းရသေးပါ',
                              style: TextStyle(
                                color: isAlreadyInstalled!(novelData)
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                      Text(
                          'Date: ${DateTime.fromMillisecondsSinceEpoch(novelData.date).toParseTime()}'),
                      // Text(
                      //     'Ago: ${DateTime.fromMillisecondsSinceEpoch(novelData.date).toAutoParseTime()}'),
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
