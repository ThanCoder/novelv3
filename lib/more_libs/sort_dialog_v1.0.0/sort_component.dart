import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/sort_dialog_v1.0.0/sort_chooser_dialog.dart';
import 'package:novel_v3/more_libs/sort_dialog_v1.0.0/sort_type.dart';

class SortComponent extends StatelessWidget {
  SortType? value;
  void Function(SortType type) onChanged;
  SortComponent({
    super.key,
    this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        final type = value ?? SortType(title: 'Title', isAsc: true);
        showAdaptiveDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => SortChooserDialog(
            type: type,
            onChanged: onChanged,
          ),
        );
      },
      icon: const Icon(Icons.sort),
    );
  }
}
