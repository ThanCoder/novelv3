import 'package:flutter/material.dart';

import 'sort_chooser_dialog.dart';
import 'sort_type.dart';

void showSortDialog(
  BuildContext context, {
  List<SortType> sortList = const [],
  required SortType value,
  bool? barrierDismissible,
  required void Function(SortType type) onChanged,
}) {
  if (sortList.isEmpty) {
    sortList = SortType.getDefaultList;
  }
  showAdaptiveDialog(
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (context) => SortChooserDialog(
      sortList: sortList,
      type: value,
      onChanged: onChanged,
    ),
  );
}
