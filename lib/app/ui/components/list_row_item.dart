import 'package:flutter/material.dart';

class ListRowItem extends StatelessWidget {
  final IconData? iconData;
  final String text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final int? maxLines;
  const ListRowItem({
    super.key,
    required this.text,
    this.iconData,
    this.fontWeight,
    this.fontSize,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(iconData),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
        ),
      ],
    );
  }
}
