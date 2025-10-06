import 'package:flutter/material.dart';
import '../../core/models/helper_file.dart';
import '../components/index.dart';

class HelperSeeAllView extends StatelessWidget {
  String title;
  List<HelperFile> list;
  Color? titleColor;
  int? showLines;
  void Function(String title, List<HelperFile> list) onSeeAllClicked;
  void Function(HelperFile helper) onClicked;
  HelperSeeAllView({
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
    return SeeAllView<HelperFile>(
      title: title,
      titleColor: titleColor,
      showLines: showLines,
      list: list,
      onSeeAllClicked: onSeeAllClicked,
      gridItemBuilder: (context, item) =>
          HelperGridItem(helper: item, onClicked: onClicked),
    );
  }
}
