import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_status_badge.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/widgets/my_image_file.dart';
import 'package:novel_v3/app/widgets/my_image_url.dart';

class NovelListView extends StatelessWidget {
  List<NovelModel> novelList;
  void Function(NovelModel novel)? onClick;
  bool isOnlineCover;
  NovelListView({
    super.key,
    required this.novelList,
    this.onClick,
    this.isOnlineCover = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: novelList.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 220,
        crossAxisSpacing: 0.5,
      ),
      itemBuilder: (context, index) => _ListItem(
        novel: novelList[index],
        isOnlineCover: isOnlineCover,
        onClick: (novel) {
          if (onClick != null) {
            onClick!(novel);
          }
        },
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  NovelModel novel;
  void Function(NovelModel novel) onClick;
  bool isOnlineCover;
  _ListItem({
    required this.novel,
    required this.onClick,
    this.isOnlineCover = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClick(novel),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: isOnlineCover
                          ? MyImageUrl(
                              url: novel.coverUrl,
                              fit: BoxFit.fill,
                              width: double.infinity,
                            )
                          : MyImageFile(
                              path: novel.coverPath,
                              fit: BoxFit.fill,
                              width: double.infinity,
                            ),
                    ),
                  ),
                ],
              ),
              novel.isAdult
                  ? Positioned(
                      top: 3,
                      left: 3,
                      child: NovelStatusBadge(
                        text: 'Adult',
                        bgColor: novelStatusAdultColor,
                      ),
                    )
                  : Container(),
              Positioned(
                top: 3,
                right: 3,
                child: NovelStatusBadge(
                  text: novel.isCompleted ? 'Completed' : 'OnGoing',
                  bgColor: novel.isCompleted
                      ? novelStatusCompletedColor
                      : novelStatusOnGoingColor,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(199, 36, 36, 36),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4)),
                  ),
                  child: Text(
                    novel.title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 12,
                      color: Colors.white,
                    ),
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
