import 'package:flutter/material.dart';

class NovelStatusBadge extends StatelessWidget {
  String text;
  Color bgColor;
  Color textColor;
  void Function()? onClicked;
  NovelStatusBadge({
    super.key,
    required this.text,
    this.bgColor = Colors.teal,
    this.textColor = Colors.white,
    this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onClicked != null) {
          onClicked!();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
