import 'package:flutter/material.dart';

class NovelConfigExportDialog extends StatefulWidget {
  void Function(bool isIncludeCover) onApply;
  NovelConfigExportDialog({super.key, required this.onApply});

  @override
  State<NovelConfigExportDialog> createState() =>
      _NovelConfigExportDialogState();
}

class _NovelConfigExportDialogState extends State<NovelConfigExportDialog> {
  bool isIncludeCover = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      scrollable: true,
      content: Column(
        children: [
          SwitchListTile.adaptive(
            title: Text('Export Cover File'),
            value: isIncludeCover,
            onChanged: (value) {
              setState(() {
                isIncludeCover = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Close'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onApply(isIncludeCover);
          },
          child: Text('Export'),
        ),
      ],
    );
  }
}
