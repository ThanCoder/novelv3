import 'package:flutter/material.dart';
import 'package:t_widgets/t_sort/index.dart';

class SortDialogAction extends StatelessWidget {
  final bool isAsc;
  final List<TSort>? sortList;
  final int? currentId;
  final TSortDialogCallback sortDialogCallback;
  const SortDialogAction({
    super.key,
    this.isAsc = true,
    this.sortList,
    this.currentId,
    required this.sortDialogCallback,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showTSortDialog(
          context,
          isAsc: isAsc,
          sortList: sortList,
          currentId: currentId,
          sortDialogCallback: sortDialogCallback,
        );
      },
      icon: Icon(Icons.sort),
    );
  }
}
