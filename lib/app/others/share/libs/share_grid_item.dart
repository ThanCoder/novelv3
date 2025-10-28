import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/share/libs/share_novel.dart';
import 'package:t_widgets/t_widgets_dev.dart';

class ShareGridItem extends StatelessWidget {
  final String hostUrl;
  final ShareNovel novel;
  final void Function(ShareNovel novel)? onClicked;
  const ShareGridItem({
    super.key,
    required this.hostUrl,
    required this.novel,
    this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked?.call(novel),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: TImage(
                        source:
                            '$hostUrl/download?path=${novel.path}/cover.png',
                        // cachePath: PathUtil.getCachePath(),
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
              Text(
                novel.title,
                style: TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 11),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
