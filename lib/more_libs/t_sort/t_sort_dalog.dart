import 'package:flutter/material.dart';
import 't_sort_list.dart';

typedef TSortDialogCallback = void Function(String field, bool isAsc);

class TSortDalog extends StatefulWidget {
  String? fieldName;
  bool isAscDefault;
  TSortList? sortList;
  Color activeColor;
  Color? activeTextColor;
  TSortDialogCallback sortDialogCallback;
  TSortDalog({
    super.key,
    required this.sortDialogCallback,
    this.isAscDefault = true,
    this.sortList,
    required this.fieldName,
    this.activeColor = Colors.teal,
    this.activeTextColor,
  });

  @override
  State<TSortDalog> createState() => _TSortDalogState();
}

class _TSortDalogState extends State<TSortDalog> {
  String fieldName = '';
  late TSortList sortList;
  bool isAsc = true;
  @override
  void initState() {
    if (widget.sortList != null) {
      sortList = widget.sortList!;
    } else {
      sortList = TSortList.getDefaultList;
    }
    fieldName = widget.fieldName ?? sortList.getFields.first;
    isAsc = widget.isAscDefault;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      // contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: [
          Text(
            "Sort",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _getListWidget(),
          SizedBox(height: 10),
          _getAscWidget(),
        ],
      ),
      actions: _getActionWidget(),
    );
  }

  Widget _getListWidget() {
    final fields = sortList.getAll.map((e) => e.field).toSet().toList();
    return Wrap(
      children: List.generate(fields.length, (index) {
        final name = fields[index];
        return GestureDetector(
          onTap: () => _onChangeFieldName(name),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Card(
              color: name == fieldName ? widget.activeColor : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  style: TextStyle(
                    color: name == fieldName ? widget.activeTextColor : null,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _getAscWidget() {
    final ascIndex = sortList.getAll.indexWhere(
      (e) => e.field == fieldName && e.isAsc,
    );
    final descIndex = sortList.getAll.indexWhere(
      (e) => e.field == fieldName && !e.isAsc,
    );
    if (ascIndex == -1 || descIndex == -1) {
      return Text(
        'Field Name:`$fieldName` Not Found!',
        style: TextStyle(color: Colors.red),
      );
    }
    final ascTitle = sortList.getAll[ascIndex].title;
    final descTitle = sortList.getAll[descIndex].title;

    return Row(
      spacing: 5,
      children: [
        Expanded(
          child: _getTextButton(
            ascTitle,
            isSelected: isAsc,
            onPressed: () {
              setState(() {
                isAsc = true;
              });
            },
          ),
        ),
        Expanded(
          child: _getTextButton(
            descTitle,
            isSelected: !isAsc,
            onPressed: () {
              setState(() {
                isAsc = false;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _getTextButton(
    String text, {
    bool isSelected = false,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: () => onPressed?.call(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? widget.activeColor : const Color(0xFF000000),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: isSelected ? widget.activeColor : null),
          ),
        ),
      ),
    );
  }

  List<Widget> _getActionWidget() {
    return [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('Cancel'),
      ),
      TextButton(
        style: TextButton.styleFrom(iconColor: Colors.teal),
        onPressed: () {
          Navigator.pop(context);
          widget.sortDialogCallback(fieldName, isAsc);
        },
        child: Text('Apply'),
      ),
    ];
  }

  void _onChangeFieldName(String name) {
    setState(() {
      fieldName = name;
    });
  }
}
