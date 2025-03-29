import 'package:flutter/material.dart';

class NovelStatusBadge extends StatelessWidget {
  String text;
  Color? textColor;
  Color? bgColor;
  void Function(String text)? onClick;
  NovelStatusBadge({
    super.key,
    required this.text,
    required this.bgColor,
    this.textColor = Colors.white,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onClick != null) {
          onClick!(text);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: bgColor,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
