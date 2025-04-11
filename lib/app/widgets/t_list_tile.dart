import 'package:flutter/material.dart';

class TListTile extends StatelessWidget {
  Widget? leading;
  Widget title;
  double spacing;
  double marginButton;
  void Function()? onTap;
  TListTile({
    super.key,
    required this.title,
    this.leading,
    this.spacing = 0.5,
    this.onTap,
    this.marginButton = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.cell,
        child: Container(
          margin: EdgeInsets.only(bottom: marginButton),
          child: Row(
            spacing: spacing,
            children: [
              leading ?? const SizedBox.shrink(),
              title,
            ],
          ),
        ),
      ),
    );
  }
}
