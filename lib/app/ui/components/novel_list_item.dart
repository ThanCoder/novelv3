import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelListItem extends StatelessWidget {
  final Novel novel;
  final void Function(Novel novel)? onClicked;
  final void Function(Novel novel)? onRightClicked;
  const NovelListItem({
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
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 3,
              children: [
                SizedBox(
                  width: 100,
                  height: 120,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: TImage(source: novel.getCoverPath),
                      ),
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
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.title),
                          Expanded(
                            child: Text(
                              novel.title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.person),
                          Expanded(child: Text(novel.meta.author)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.sd_card),
                          Expanded(
                            child: Text(novel.getSize().toFileSizeLabel()),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.date_range),
                          Expanded(child: Text(novel.getDate.toParseTime())),
                        ],
                      ),
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
