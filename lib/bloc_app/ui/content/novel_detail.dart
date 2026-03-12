import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/components/expandable_tags.dart';
import 'package:novel_v3/core/models/novel.dart';

class NovelDetail extends StatelessWidget {
  final Novel novel;
  const NovelDetail({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(4.0),
      children: [
        ExpandableTags(list: novel.meta.tags),
        novel.meta.tags.isNotEmpty ? Divider() : SizedBox.shrink(),
        SelectableText(novel.meta.desc),
      ],
    );
  }
}
