import 'package:flutter/material.dart';

import 'package:t_widgets/t_widgets.dart';

import '../novel_v3_uploader.dart';

class OnlineNovelGridItem extends StatelessWidget {
  UploaderNovel novel;
  void Function(UploaderNovel novel) onClicked;
  OnlineNovelGridItem({
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
        child: Stack(
          children: [
            Positioned.fill(
              child: TCacheImage(
                url: novel.coverUrl,
                fit: BoxFit.fill,
                width: double.infinity,
                cachePath: NovelV3Uploader.instance.imageCachePath,
              ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),

            // title
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(178, 0, 0, 0),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  novel.title,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              top: 0,
              child: StatusText(
                bgColor: novel.isCompleted
                    ? StatusText.completedColor
                    : StatusText.onGoingColor,
                text: novel.isCompleted ? 'Completed' : 'OnGoing',
              ),
            ),
            novel.isAdult
                ? Positioned(
                    right: 0,
                    top: 0,
                    child: StatusText(
                      text: 'Adult',
                      bgColor: StatusText.adultColor,
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
