import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/index.dart';

class ReadedEditDialog extends StatefulWidget {
  BuildContext dialogContext;
  int readed;
  ReadedEditDialog({
    super.key,
    required this.dialogContext,
    required this.readed,
  });

  @override
  State<ReadedEditDialog> createState() => _ReadedEditDialogState();
}

class _ReadedEditDialogState extends State<ReadedEditDialog> {
  TextEditingController readedTextController = TextEditingController();
  @override
  void initState() {
    readedTextController.text = widget.readed.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Readed'),
      content: SizedBox(
        height: 100,
        child: Column(
          children: [
            TTextField(
              controller: readedTextController,
              label: const Text('Readed'),
              textInputType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Update'),
        ),
      ],
    );
  }
}
