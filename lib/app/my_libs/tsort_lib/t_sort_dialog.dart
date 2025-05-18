import 'package:flutter/material.dart';
import 'package:novel_v3/app/my_libs/tsort_lib/t_sort.dart';

class TSortDialog extends StatefulWidget {
  List<TSort> list;
  TSort? value;
  void Function(String title, String choose)? onChoosed;
  TSortDialog({
    super.key,
    required this.list,
    this.value,
    this.onChoosed,
  });

  @override
  State<TSortDialog> createState() => _TSortDialogState();
}

class _TSortDialogState extends State<TSortDialog> {
  @override
  void initState() {
    if (widget.value == null && widget.list.isNotEmpty) {
      value = widget.list.first;
      title = value!.title;
      choose = value!.choose.first;
    }
    if (widget.value != null) {
      final res = widget.list.where((e) => e.title == widget.value!.title);
      value = res.first;
      title = value!.title;
      choose = widget.value!.choose.first;
    }
    super.initState();
    init();
  }

  TSort? value;
  late String title;
  late String choose;

  void init() {}

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: [
          // title
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.list
                .map(
                  (ts) => Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: title == ts.title ? Colors.blue : null,
                    ),
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            value = ts;
                            choose = ts.choose.first;
                            title = ts.title;
                          });
                        },
                        child: Text(ts.title)),
                  ),
                )
                .toList(),
          ),
          // choose
          value == null ? const SizedBox.shrink() : const Divider(),
          value == null
              ? const SizedBox.shrink()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 5,
                  children: value!.choose
                      .map(
                        (ch) => Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  choose == ch ? Colors.teal : null,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                choose = ch;
                              });
                            },
                            child: Text(ch),
                          ),
                        ),
                      )
                      .toList(),
                )
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
            if (widget.onChoosed != null) {
              widget.onChoosed!(title, choose);
            }
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
