import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';

class WrapListTile extends StatelessWidget {
  Widget? title;
  List<String> list;
  void Function(String name) onClicked;
  WrapListTile({
    super.key,
    this.title,
    required this.list,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            title == null ? SizedBox.shrink() : title!,

            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: list
                  .map(
                    (e) => TChip(title: Text(e), onClick: () => onClicked(e)),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
