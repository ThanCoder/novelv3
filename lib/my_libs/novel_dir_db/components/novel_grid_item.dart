import 'package:flutter/material.dart';
import 'package:t_widgets/widgets/index.dart';
import '../novel_dir_db.dart';

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
    return Stack(
      children: [
        Positioned.fill(child: TImage(source: novel.path)),
        Container(color: Colors.black.withValues(alpha: 0.2),),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Text(novel.title,maxLines: 2,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,style: TextStyle(fontSize: 12),)),
          // status
      ],
    );
  }
}
