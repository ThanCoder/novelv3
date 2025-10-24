import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import '../../../../novel_dir_app.dart';

class NovelSeeAllView extends StatelessWidget {
  final String title;
  final List<Novel> list;
  final EdgeInsetsGeometry padding;
  final void Function(Novel novel)? onRightClicked;
  final void Function(Novel novel) onClicked;
  const NovelSeeAllView({
    super.key,
    required this.title,
    required this.list,
    required this.onClicked,
    this.padding = const EdgeInsets.all(8.0),
    this.onRightClicked,
  });

  @override
  Widget build(BuildContext context) {
    return TSeeAllView<Novel>(
      title: title,
      list: list,
      itemWidth: 120,
      itemHeight: 150,
      viewHeight: 170,
      showCount: 8,
      gridItemBuilder: (context, item) => NovelGridItem(
        novel: item,
        onClicked: onClicked,
        onRightClicked: onRightClicked,
      ),
    );
  }
}
