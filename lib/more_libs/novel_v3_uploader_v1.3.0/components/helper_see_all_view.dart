import 'package:flutter/material.dart';
import '../models/helper_file.dart';
import 'index.dart';

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
      itemBuilder: (context, index) =>
          HelperGridItem(helper: list[index], onClicked: onClicked),
    );
  }
}
