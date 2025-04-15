import 'package:flutter/material.dart';
import 'package:novel_v3/app/widgets/index.dart';

class TagsWrapView extends StatelessWidget {
  String title;
  String values;
  void Function()? onAddClicked;
  void Function(String value)? onDeleted;
  void Function(String value)? onClicked;
  void Function(String values)? onApply;
  TagsWrapView({
    super.key,
    required this.title,
    required this.values,
    this.onAddClicked,
    this.onDeleted,
    this.onClicked,
    this.onApply,
  });

  List<String> get _getList {
    return values.split(',').where((name) => name.isNotEmpty).toList();
  }

  List<Widget> _getWidgetList() {
    return List.generate(
      _getList.length,
      (index) {
        final name = _getList[index];
        return TChip(
          title: name,
          onDelete: onDeleted != null ? () => onDeleted!(name) : null,
          onClick: onClicked != null ? () => onClicked!(name) : null,
        );
      },
    );
  }

  Widget _addButton() {
    if (onAddClicked == null) {
      return const SizedBox.shrink();
    }
    return IconButton(
      color: Colors.green,
      onPressed: onAddClicked,
      icon: const Icon(Icons.add_circle_outlined),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Text(title),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            ..._getWidgetList(),
            _addButton(),
          ],
        ),
      ],
    );
  }
}
