import 'package:flutter/material.dart';

class TagWrapView extends StatelessWidget {
  List<String> list;
  void Function(String name)? onClicked;
  TagWrapView({super.key, required this.list, this.onClicked});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: List.generate(list.length, (index) {
        final item = list[index];
        return MouseRegion(
          cursor: onClicked == null
              ? MouseCursor.defer
              : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              if (onClicked == null) return;
              onClicked!(item);
            },
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black.withValues(alpha: 0.2),
              ),
              child: Text(item, style: TextStyle(fontSize: 13)),
            ),
          ),
        );
      }),
    );
  }
}
