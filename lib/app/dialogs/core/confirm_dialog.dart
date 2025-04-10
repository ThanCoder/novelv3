import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  String title;
  String contentText;
  String cancelText;
  String submitText;
  void Function() onCancel;
  void Function() onSubmit;
  ConfirmDialog({
    super.key,
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
            Navigator.of(context).pop(true);
            onCancel();
          },
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onSubmit();
          },
          child: Text(submitText),
        ),
      ],
    );
  }
}
