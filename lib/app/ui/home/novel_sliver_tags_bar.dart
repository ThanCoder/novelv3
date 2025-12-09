import 'package:flutter/material.dart';

const novelSliverTags = [
  'Latest',
  'BookMark',
  'Completed',
  'OnGoing',
  'No Adult',
  'Adult',
];

class NovelSliverTagsBar extends StatefulWidget {
  final String? value;
  final void Function(String tag)? onChoosed;
  const NovelSliverTagsBar({super.key, this.value, this.onChoosed});

  @override
  State<NovelSliverTagsBar> createState() => _NovelTagsBarState();
}

class _NovelTagsBarState extends State<NovelSliverTagsBar> {
  late String current;
  @override
  void initState() {
    current = widget.value ?? novelSliverTags.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      snap: true,
      floating: true,
      pinned: false,
      toolbarHeight: 40,
      flexibleSpace: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            spacing: 3,
            children: novelSliverTags.map((tag) => _getItem(tag)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _getItem(String text) {
    return GestureDetector(
      onTap: () {
        current = text;
        setState(() {});
        widget.onChoosed?.call(text);
      },
      child: Chip(
        avatar: current == text ? Icon(Icons.check) : null,
        label: Text(text),
        mouseCursor: SystemMouseCursors.click,
        padding: EdgeInsets.all(5),
      ),
    );
  }
}
