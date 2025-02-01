import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_status_badge.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/novel_data_model.dart';
import 'package:novel_v3/app/utils/app_util.dart';
import 'package:novel_v3/app/widgets/my_image_file.dart';

class NovelDataListView extends StatelessWidget {
  List<NovelDataModel> novelDataList;
  void Function(NovelDataModel novelData)? onClick;
  void Function(NovelDataModel novelData)? onLongClick;
  NovelDataListView({
    super.key,
    required this.novelDataList,
    this.onClick,
    this.onLongClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => _ListItem(
        novelData: novelDataList[index],
        onClick: (novelData) {
          if (onClick != null) {
            onClick!(novelData);
          }
        },
        onLongClick: (novelData) {
          if (onLongClick != null) {
            onLongClick!(novelData);
          }
        },
      ),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: novelDataList.length,
    );
  }
}

class _ListItem extends StatelessWidget {
  NovelDataModel novelData;
  void Function(NovelDataModel novelData) onClick;
  void Function(NovelDataModel novelData) onLongClick;
  _ListItem({
    super.key,
    required this.novelData,
    required this.onClick,
    required this.onLongClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClick(novelData),
      onLongPress: () => onLongClick(novelData),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          child: Row(
            children: [
              SizedBox(
                width: 130,
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: MyImageFile(
                    path: novelData.coverPath,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              //content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(novelData.title),
                      Wrap(
                        children: [
                          novelData.isAdult
                              ? NovelStatusBadge(
                                  text: 'Adult', bgColor: Colors.red)
                              : Container(),
                          NovelStatusBadge(
                            text:
                                novelData.isCompleted ? 'Completed' : 'OnGoing',
                            bgColor: novelData.isCompleted
                                ? novelStatusCompletedColor
                                : novelStatusOnGoingColor,
                          ),
                        ],
                      ),
                      Text(
                          'Size: ${getParseFileSize(novelData.size.toDouble())}'),
                      novelData.isAlreadyExists
                          ? Text(
                              'ရှိနေပြီးသားပါ!',
                              style: TextStyle(
                                color: Colors.red[900],
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              'မသွင်းရသေးပါ',
                              style: TextStyle(
                                color: Colors.green[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      Text('Date: ${getParseDate(novelData.date)}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
