import 'package:flutter/material.dart';

class FontListWiget extends StatelessWidget {
  int fontSize;
  void Function(int fontSize) onChange;
  int fontGenLength;
  // fontSize > fontGT(range)
  int fontGT;
  FontListWiget(
      {super.key,
      required this.fontSize,
      required this.onChange,
      this.fontGenLength = 50,
      this.fontGT = 14});

  List<DropdownMenuItem<int>> getFontList() => List.generate(
        fontGenLength,
        (index) => DropdownMenuItem<int>(
          value: index,
          child: Text('$index'),
        ),
      ).where((i) => i.value! > fontGT).toList();

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: fontSize,
      items: getFontList(),
      onChanged: (value) {
        onChange(value!);
      },
    );
  }
}
