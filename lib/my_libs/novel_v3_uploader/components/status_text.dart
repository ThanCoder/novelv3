import 'package:flutter/material.dart';

class StatusText extends StatelessWidget {
  static Color onGoingColor = const Color.fromARGB(213, 6, 124, 112);
  static Color completedColor = const Color.fromARGB(221, 13, 31, 90);
  static Color adultColor = const Color.fromARGB(210, 189, 36, 25);

  String text;
  Color textColor;
  Color bgColor;
  bool isSmallSize;
  void Function(String text)? onClicked;
  StatusText({
    super.key,
    required this.text,
    this.textColor = Colors.white,
    this.bgColor = const Color.fromARGB(225, 3, 78, 71),
    this.onClicked,
    this.isSmallSize = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallSize ? 2 : 4,
        horizontal: isSmallSize ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: isSmallSize ? 11 : 13,
        ),
      ),
    );
  }
}
