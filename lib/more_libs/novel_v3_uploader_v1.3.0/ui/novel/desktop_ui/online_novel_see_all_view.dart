import 'package:flutter/material.dart';
import '../../../novel_v3_uploader.dart';
import 'online_novel_grid_item.dart';
import '../../components/see_all_view.dart';

class OnlineNovelSeeAllView extends StatelessWidget {
  String title;
  List<Novel> list;
  Color? titleColor;
  int? showLines;
  void Function(String title, List<Novel> list) onSeeAllClicked;
  void Function(Novel novel) onClicked;
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
    return SeeAllView<Novel>(
      title: title,
      titleColor: titleColor,
      showLines: showLines,
      list: list,
      onSeeAllClicked: onSeeAllClicked,
      gridItemBuilder: (context, item) => SizedBox(
        width: 140,
        height: 180,
        child: OnlineNovelGridItem(novel: item, onClicked: onClicked),
      ),
    );
  }
}
