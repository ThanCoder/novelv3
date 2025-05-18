import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/status_text.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:t_widgets/t_widgets.dart';

class NovelOnlineGridItem extends StatelessWidget {
  String url;
  NovelModel novel;
  double fontSize;
  void Function(NovelModel novel) onClicked;
  NovelOnlineGridItem({
    super.key,
    required this.url,
    required this.novel,
    required this.onClicked,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(novel),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          children: [
            // cover
            Column(
              children: [
                Expanded(
                  child: TImageUrl(
                    url: '$url/download?path=${novel.coverPath}',
                    fit: BoxFit.fill,
                    width: double.infinity,
                  ),
                ),
              ],
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
                    fontSize: fontSize,
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
