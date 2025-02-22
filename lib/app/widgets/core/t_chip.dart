import 'package:flutter/material.dart';

class TChip extends StatelessWidget {
  String title;
  Widget? avatar;
  void Function()? onClick;
  void Function()? onDelete;
  TChip({
    super.key,
    required this.title,
    this.avatar,
    this.onClick,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onClick,
        child: Chip(
          deleteIconColor: Colors.red[900],
          label: Text(title),
          avatar: avatar,
          onDeleted: onDelete,
        ),
      ),
    );
  }
}
