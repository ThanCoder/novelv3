import 'package:flutter/material.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';

typedef NovelAlertDialogButtonCallback =
    Widget Function(BuildContext alertContext);

void showNovelAlertDialog(
  BuildContext context, {
  required Widget content,
  bool barrierDismissible = true,
  bool showButtonActions = true,
  Widget? title,
  NovelAlertDialogButtonCallback? cancelButton,
  NovelAlertDialogButtonCallback? submitButton,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => NovelAlertDialog(
      title: title,
      content: content,
      showButtonActions: showButtonActions,
      cancelButton: cancelButton,
      submitButton: submitButton,
    ),
  );
}

class NovelAlertDialog extends StatefulWidget {
  final Widget? title;
  final Widget content;
  final NovelAlertDialogButtonCallback? cancelButton;
  final NovelAlertDialogButtonCallback? submitButton;
  final bool showButtonActions;
  const NovelAlertDialog({
    super.key,
    this.title,
    required this.content,
    this.cancelButton,
    this.submitButton,
    this.showButtonActions = true,
  });

  @override
  State<NovelAlertDialog> createState() => _NovelAlertDialogState();
}

class _NovelAlertDialogState extends State<NovelAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      scrollable: true,
      title: widget.title ?? Text('Alert Dialog'),
      content: Column(
        children: [widget.content, if (widget.showButtonActions) _buttons()],
      ),
    );
  }

  Widget _buttons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.cancelButton != null)
            widget.cancelButton!(context)
          else
            TextButton(
              onPressed: () {
                context.closeNavigator();
              },
              child: Text('Cancel'),
            ),
          if (widget.submitButton != null)
            widget.submitButton!(context)
          else
            TextButton(
              onPressed: () {
                context.closeNavigator();
              },
              child: Text('Submit'),
            ),
        ],
      ),
    );
  }
}
