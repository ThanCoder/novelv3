import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';

import 'sort_type.dart';

class SortChooserDialog extends StatefulWidget {
  SortType type;
  void Function(SortType type) onChanged;
  SortChooserDialog({
    super.key,
    required this.type,
    required this.onChanged,
  });

  @override
  State<SortChooserDialog> createState() => _SortChooserDialogState();
}

class _SortChooserDialogState extends State<SortChooserDialog> {
  bool isSorted = true;
  late SortType type;

  @override
  void initState() {
    type = widget.type;
    super.initState();
  }

  List<Widget> get _getSortList {
    return SortType.getDefaultList
        .map(
          (e) => TChip(
            avatar: e.title == type.title ? const Icon(Icons.check) : null,
            title: Text(e.title),
            onClick: () {
              type = e;
              setState(() {});
            },
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      scrollable: true,
      title: const Text('Sort'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //title
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: _getSortList,
          ),
          const Divider(),
          //sort
          Row(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TChip(
                avatar: type.isAsc ? const Icon(Icons.check) : null,
                title: const Text('Asc'),
                onClick: () {
                  type.isAsc = true;
                  setState(() {});
                },
              ),
              TChip(
                avatar: !type.isAsc ? const Icon(Icons.check) : null,
                title: const Text('Desc'),
                onClick: () {
                  type.isAsc = false;
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onChanged(type);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
