import 'package:flutter/material.dart';

class PageUrlDialog extends StatelessWidget {
  final List<String> list;
  final Widget? title;
  final void Function(String url)? onClicked;
  final void Function(String url)? onRightClicked;
  const PageUrlDialog({
    super.key,
    required this.list,
    this.onClicked,
    this.onRightClicked,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: title ?? Text('Page Url'),
      scrollable: true,
      content: Column(
        children: List.generate(list.length, (index) {
          final url = list[index];
          return ListTile(
            title: Text(
              url,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14),
            ),
            onTap: () {
              Navigator.pop(context);
              onClicked?.call(url);
            },
            onLongPress: () {
              Navigator.pop(context);
              onRightClicked?.call(url);
            },
          );
        }),
      ),
    );
  }
}
