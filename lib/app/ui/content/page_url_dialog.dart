import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';

class PageUrlDialog extends StatelessWidget {
  final List<String> list;
  final Widget? submitText;
  final void Function(String url)? onClicked;
  final void Function(String url)? onRightClicked;
  final void Function()? onClose;
  final void Function()? onSubmit;
  const PageUrlDialog({
    super.key,
    required this.list,
    this.onClicked,
    this.onRightClicked,
    this.onClose,
    this.onSubmit,
    this.submitText,
  });

  @override
  Widget build(BuildContext context) {
    return TListDialog<String>(
      list: list,
      listItemBuilder: (context, item) => ListTile(
        title: Text(item, style: TextStyle(fontSize: 13), maxLines: 2),
        onTap: () {
          Navigator.pop(context);
          onClicked?.call(item);
        },
        onLongPress: () {
          onRightClicked?.call(item);
        },
      ),
      submitText: submitText ?? Text('Go Url'),
      onClose: onClose,
      onSubmit: onSubmit,
    );
  }
}
