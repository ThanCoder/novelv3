import 'package:flutter/material.dart';
import 'package:novel_v3/app/widgets/index.dart';

class AuthorWrapView extends StatelessWidget {
  String title;
  List<String> list;
  void Function(String title) onClicked;
  AuthorWrapView(
      {super.key,
      required this.title,
      required this.list,
      required this.onClicked});

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
          children: List.generate(
            list.length,
            (index) {
              final title = list[index];
              return TChip(
                title: '#$title',
                onClick: () => onClicked(title),
              );
            },
          ),
        ),
      ],
    );
  }
}
