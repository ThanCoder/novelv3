import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/share/libs/share_novel.dart';
import 'package:t_widgets/widgets/t_image.dart';

class ShareGridItem extends StatelessWidget {
  final String url;
  final ShareNovel novel;
  final void Function(ShareNovel novel)? onClicked;
  const ShareGridItem({
    super.key,
    required this.url,
    required this.novel,
    this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked?.call(novel),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          children: [
            Positioned.fill(
              child: TImage(
                source: '$url/download?path=${novel.path}/cover.png',
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(169, 22, 22, 22),
                ),
                child: Text(
                  novel.title,
                  style: TextStyle(
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: _getStatus(
                novel.isCompleted ? 'Completed' : 'OnGoing',
                bgColor: novel.isCompleted
                    ? const Color.fromARGB(255, 4, 121, 109)
                    : const Color.fromARGB(255, 7, 97, 92),
              ),
            ),
            !novel.isAdult
                ? SizedBox.shrink()
                : Positioned(
                    right: 0,
                    top: 0,
                    child: _getStatus(
                      'Adult',
                      bgColor: const Color.fromARGB(255, 165, 30, 20),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _getStatus(String text, {Color bgColor = Colors.blue}) {
    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 13)),
    );
  }
}
