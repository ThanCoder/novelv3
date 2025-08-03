import 'package:flutter/material.dart';
import '../models/uploader_novel.dart';
import 'online_novel_grid_item.dart';
import 'see_all_view.dart';

class OnlineNovelSeeAllView extends StatelessWidget {
  String title;
  List<UploaderNovel> list;
  Color? titleColor;
  int? showLines;
  void Function(String title, List<UploaderNovel> list) onSeeAllClicked;
  void Function(UploaderNovel novel) onClicked;
  OnlineNovelSeeAllView({
    super.key,
    required this.title,
    required this.list,
    required this.onSeeAllClicked,
    required this.onClicked,
    this.titleColor,
    this.showLines,
  });

  @override
  Widget build(BuildContext context) {
    return SeeAllView<UploaderNovel>(
      title: title,
      titleColor: titleColor,
      showLines: showLines,
      list: list,
      onSeeAllClicked: onSeeAllClicked,
      itemBuilder: (context, index) =>
          OnlineNovelGridItem(novel: list[index], onClicked: onClicked),
    );
  }
}
