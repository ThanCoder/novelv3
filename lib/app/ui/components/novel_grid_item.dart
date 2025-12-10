import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';

class NovelGridItem extends StatelessWidget {
  final Novel novel;
  final void Function(Novel novel)? onClicked;
  final void Function(Novel novel)? onRightClicked;
  const NovelGridItem({
    super.key,
    required this.novel,
    this.onClicked,
    this.onRightClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked?.call(novel),
      onLongPress: () => onRightClicked?.call(novel),
      onSecondaryTap: () => onRightClicked?.call(novel),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: SizedBox(
              width: 100,
              height: 120,
              child: Stack(
                children: [
                  Positioned.fill(child: TImage(source: novel.getCoverPath)),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                  // adult
                  !novel.meta.isAdult
                      ? SizedBox.shrink()
                      : Positioned(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.person_add_outlined,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                  // completed
                  Positioned(
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        novel.meta.isCompleted
                            ? Icons.check_circle
                            : Icons.incomplete_circle,
                        color: novel.meta.isCompleted
                            ? Colors.green
                            : Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                  // title
                  Positioned(
                    left: 0,
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      child: Text(
                        novel.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
