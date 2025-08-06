import 'package:flutter/material.dart';
import '../novel_dir_db.dart';

class NovelSeeAllView extends StatelessWidget {
  String title;
  List<Novel> list;
  void Function(Novel novel) onClicked;
  void Function(String title, List<Novel> list) onSeeAllClicked;
  NovelSeeAllView({
    super.key,
    required this.title,
    required this.list,
    required this.onClicked,
    required this.onSeeAllClicked,
  });

  @override
  Widget build(BuildContext context) {
    return SeeAllView<Novel>(
      title: title,
      list: list,
      showMoreButtonBottomPos: true,
      onSeeAllClicked: onSeeAllClicked,
      gridItemBuilder: (context, item) =>
          NovelGridItem(novel: item, onClicked: onClicked),
    );
  }
}
