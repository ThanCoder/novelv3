import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:t_widgets/t_widgets.dart';

class AddBookmarkTitleDialog extends StatefulWidget {
  ChapterModel chapter;
  void Function(String title, int readLine) onSubmit;
  int readLine;
  String submitText;
  String cancelText;
  AddBookmarkTitleDialog({
    super.key,
    required this.chapter,
    required this.onSubmit,
    this.readLine = 0,
    this.submitText='Submit',
    this.cancelText='Cancel'
  });

  @override
  State<AddBookmarkTitleDialog> createState() => _AddBookmarkTitleDialogState();
}

class _AddBookmarkTitleDialogState extends State<AddBookmarkTitleDialog> {
  final titleController = TextEditingController();
  final lineController = TextEditingController();
  @override
  void initState() {
    lineController.text = widget.readLine.toString();
    super.initState();
    fetch();
  }

  void fetch() {
    if (int.tryParse(lineController.text) == null) return;
    titleController.text =
        widget.chapter.getTitle(readLine: int.parse(lineController.text));
  }

  @override
  void dispose() {
    titleController.dispose();
    lineController.dispose();
    super.dispose();
  }

  int get _getReadLine {
    if (int.tryParse(lineController.text) == null) return widget.readLine;
    return int.parse(lineController.text);
  }
  void _submit(){
    Navigator.of(context).pop(true);

    widget.onSubmit(titleController.text, _getReadLine);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: Column(
        spacing: 5,
        children: [
          TTextField(
            label: const Text('Read Line Number'),
            controller: lineController,
            maxLines: 1,
            textInputType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              fetch();
            },
            onSubmitted: (value) => _submit,
          ),
          TTextField(
            label: const Text('Title'),
            controller: titleController,
            maxLines: 1,
            onSubmitted: (value) => _submit,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(widget.cancelText),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(widget.submitText),
        ),
      ],
    );
  }
}
