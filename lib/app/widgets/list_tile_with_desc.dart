import 'package:flutter/material.dart';

class ListTileWithDesc extends StatelessWidget {
  String title;
  String? desc;
  Widget? trailing;
  Widget? leading;
  double spacing;
  void Function()? onClick;
  ListTileWithDesc({
    super.key,
    required this.title,
    this.trailing,
    this.desc,
    this.leading,
    this.spacing = 10,
    this.onClick,
  });

  Widget _getLeading() {
    if (leading == null) {
      return Container();
    }
    return leading!;
  }

  Widget _getTrailing() {
    if (trailing == null) {
      return Container();
    }
    return trailing!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onClick != null) {
          onClick!();
        }
      },
      child: MouseRegion(
        cursor: onClick != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: spacing,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _getLeading(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                      ),
                      desc != null ? const SizedBox(height: 5) : Container(),
                      desc != null
                          ? Text(
                              desc ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            )
                          : Container(),
                    ],
                  ),
                ),
                _getTrailing(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
