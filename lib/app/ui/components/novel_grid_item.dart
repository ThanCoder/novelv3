import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:t_widgets/widgets/index.dart';
import '../novel_dir_app.dart';

class NovelGridItem extends StatelessWidget {
  Novel novel;
  void Function(Novel novel) onClicked;
  void Function(Novel novel)? onRightClicked;
  NovelGridItem({
    super.key,
    required this.novel,
    required this.onClicked,
    this.onRightClicked,
  });

  @override
  Widget build(BuildContext context) {
    // print('Adult :${novel.meta.isAdult}');
    return GestureDetector(
      onTap: () => onClicked(novel),
      onSecondaryTap: () => onRightClicked?.call(novel),
      onLongPress: () => onRightClicked?.call(novel),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            spacing: 5,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(child: TImage(source: novel.getCoverPath)),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    // status
                    Positioned(
                      left: 0,
                      top: 0,
                      child: StatusText(
                        bgColor: novel.meta.isCompleted
                            ? StatusText.completedColor
                            : StatusText.onGoingColor,
                        text: novel.meta.isCompleted ? 'Completed' : 'OnGoing',
                      ),
                    ),
                    novel.meta.isAdult
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
              Padding(
                padding: EdgeInsetsGeometry.only(bottom: 4),
                child: Text(
                  novel.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ).animate().scaleXY(duration: Duration(milliseconds: 700)),
      ),
    );
  }
}
