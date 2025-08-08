import 'package:flutter/material.dart';
import '../novel_dir_db.dart';

class NovelSeeAllView extends StatelessWidget {
  String title;
  List<Novel> list;
  NovelSeeAllView({
    super.key,
    required this.title,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    return SeeAllView<Novel>(
      title: title,
      list: list,
      showMoreButtonBottomPos: false,
      onSeeAllClicked: (title, list) =>
          goNovelSeeAllScreen(context, title, list),
      gridItemBuilder: (context, item) => NovelGridItem(
        novel: item,
        onClicked: (novel) => goContentScreen(context, novel),
      ),
    );
  }
}
