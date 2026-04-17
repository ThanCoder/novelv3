import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/components/novel_list_item.dart';
import 'package:novel_v3/core/models/novel.dart';

class SliverListStyle extends StatelessWidget {
  final List<Novel> list;
  final void Function(Novel novel)? onClicked;
  final void Function(Novel novel)? onRightClicked;
  const SliverListStyle({
    super.key,
    required this.list,
    this.onClicked,
    this.onRightClicked,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => _item(list[index]),
    );
  }

  Widget _item(Novel novel) {
    return NovelListItem(
      novel: novel,
      onClicked: onClicked,
      onRightClicked: onRightClicked,
    );
  }
}
