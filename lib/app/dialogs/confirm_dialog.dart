import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  BuildContext dialogContext;
  String title;
  String contentText;
  String cancelText;
  String submitText;
  void Function() onCancel;
  void Function() onSubmit;
  ConfirmDialog({
    super.key,
    required this.dialogContext,
    this.title = 'အတည်ပြုခြင်း',
    this.contentText = '',
    this.cancelText = 'Cancel',
    this.submitText = 'Submit',
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(contentText),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            onCancel();
          },
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            onSubmit();
          },
          child: Text(submitText),
        ),
      ],
    );
  }
}
