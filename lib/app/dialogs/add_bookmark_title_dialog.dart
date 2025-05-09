import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/widgets/core/t_text_field.dart';

class AddBookmarkTitleDialog extends StatefulWidget {
  ChapterModel chapter;
  void Function(String title, int readLine) onSubmit;
  int readLine;
  AddBookmarkTitleDialog({
    super.key,
    required this.chapter,
    required this.onSubmit,
    this.readLine = 0,
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
          ),
          TTextField(
            label: const Text('Title'),
            controller: titleController,
            maxLines: 1,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            widget.onSubmit(titleController.text, _getReadLine);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
