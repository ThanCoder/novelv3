import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';

class AddAutoMultiChapterFormDialog extends StatefulWidget {
  final int start;
  final int end;
  final void Function(int choosedStart, int choosedEnd) onSubmit;
  const AddAutoMultiChapterFormDialog({
    super.key,
    required this.start,
    required this.end,
    required this.onSubmit,
  });

  @override
  State<AddAutoMultiChapterFormDialog> createState() =>
      _AddAutoMultiChapterFormDialogState();
}

class _AddAutoMultiChapterFormDialogState
    extends State<AddAutoMultiChapterFormDialog> {
  @override
  void initState() {
    startController.text = widget.start.toString();
    endController.text = widget.end.toString();
    super.initState();
  }

  final startController = TextEditingController();
  final endController = TextEditingController();
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text('Add Auto Chapter Range Form'),
      content: TScrollableColumn(
        children: [
          Text('Chapter Range ${widget.start}-${widget.end}'),
          errorText == null
              ? SizedBox.shrink()
              : Text(
                  '[Error]: $errorText',
                  style: TextStyle(color: Colors.red),
                ),
          TNumberField(
            label: Text('Start'),
            maxLines: 1,
            controller: startController,
            onChanged: (text) {
              if (text.isEmpty) return;
              if (endController.text.isEmpty) return;
              int current = int.parse(text);
              if (current > int.parse(endController.text)) {
                setState(() {
                  errorText =
                      'End Number `${endController.text}` ထက်ကြီးမရပါ!...';
                });
              } else {
                if (errorText != null) {
                  setState(() {
                    errorText = null;
                  });
                }
              }
            },
          ),
          TNumberField(
            label: Text('End'),
            maxLines: 1,
            controller: endController,
            onChanged: (text) {
              if (text.isEmpty) return;
              if (startController.text.isEmpty) return;
              int current = int.parse(text);
              if (current < int.parse(startController.text)) {
                setState(() {
                  errorText =
                      'Start Number `${startController.text}` ငယ်မရပါ!...';
                });
              } else {
                if (errorText != null) {
                  setState(() {
                    errorText = null;
                  });
                }
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: errorText != null
              ? null
              : () {
                  Navigator.pop(context);
                  final start = startController.text;
                  final end = endController.text;
                  widget.onSubmit(int.parse(start), int.parse(end));
                },
          child: Text('Start'),
        ),
      ],
    );
  }
}
