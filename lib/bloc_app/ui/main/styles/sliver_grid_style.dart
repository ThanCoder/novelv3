import 'package:flutter/material.dart';
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
        maxCrossAxisExtent: 200,
        mainAxisExtent: 220,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
      ),
      itemBuilder: (context, index) => _item(list[index]),
    );
  }

  Widget _item(Novel novel) {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () => onClicked?.call(novel),
      onLongPress: () => onRightClicked?.call(novel),
      onSecondaryTap: () => onRightClicked?.call(novel),
      child: Stack(
        fit: StackFit.expand,
        children: [
          TImage(source: novel.getCoverPath),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
              ),
              child: Text(
                novel.meta.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
