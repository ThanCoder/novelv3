import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/t_sort/funcs.dart';
import 't_sort_dalog.dart';
import 't_sort_list.dart';

class TSortActionButton extends StatelessWidget {
  String fieldName;
  TSortList sortList;
  TSortDialogCallback sortDialogCallback;
  bool isAscDefault;
  Color activeColor;
  Color? activeTextColor;
  TSortActionButton({
    super.key,
    required this.fieldName,
    required this.sortList,
    required this.sortDialogCallback,
    this.isAscDefault = true,
    this.activeColor = Colors.teal,
    this.activeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showTSortDialog(
          context,
          fieldName: fieldName,
          sortList: sortList,
          sortDialogCallback: sortDialogCallback,
          activeColor: activeColor,
          activeTextColor: activeTextColor,
          isAscDefault: isAscDefault,
        );
      },
      icon: Icon(Icons.sort),
    );
  }
}
