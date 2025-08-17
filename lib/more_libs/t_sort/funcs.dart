import 'package:flutter/material.dart';
import 't_sort_list.dart';
import 't_sort_dalog.dart';

void showTSortDialog(
  BuildContext context, {
  required String fieldName,
  required TSortList sortList,
  required TSortDialogCallback sortDialogCallback,
  bool isAscDefault = true,
  required Color activeColor,
  Color? activeTextColor,
}) {
  showAdaptiveDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => TSortDalog(
      fieldName: fieldName,
      sortList: sortList,
      sortDialogCallback: sortDialogCallback,
      isAscDefault: isAscDefault,
      activeColor: activeColor = Colors.teal,
      activeTextColor: activeTextColor,
    ),
  );
}
