import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/components/novel_bookmark_toggler.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';

class SliverGridStyle extends StatelessWidget {
  final List<Novel> list;
  final void Function(Novel novel)? onClicked;
  final void Function(Novel novel)? onRightClicked;
  const SliverGridStyle({
    super.key,
    required this.list,
    this.onClicked,
    this.onRightClicked,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      itemCount: list.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 170,
        mainAxisExtent: 190,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
      ),
      itemBuilder: (context, index) => _item(list[index], context),
    );
  }

  Widget _item(Novel novel, BuildContext context) {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () => onClicked?.call(novel),
      onLongPress: () => onRightClicked?.call(novel),
      onSecondaryTap: () => onRightClicked?.call(novel),
      child: Stack(
        fit: StackFit.expand,
        children: [
          TImage(source: novel.getCoverPath),
          // title
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: context.isAppDark
                    ? Colors.black.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.8),
              ),
              child: Text(
                novel.meta.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.isAppDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
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
                color: novel.meta.isCompleted ? Colors.green : Colors.blue,
                size: 20,
              ),
            ),
          ),
          // bookmark
          Positioned(
            bottom: 10,
            left: 0,
            child: NovelBookmarkToggler(novel: novel),
          ),
        ],
      ),
    );
  }
}
