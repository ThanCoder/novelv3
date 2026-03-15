import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/components/expandable_tags.dart';
import 'package:novel_v3/bloc_app/ui/content/novel_info.dart';
import 'package:novel_v3/bloc_app/ui/content/novel_page_component.dart';
import 'package:novel_v3/bloc_app/ui/content/readed_component.dart';
import 'package:novel_v3/core/models/novel.dart';

class NovelDetail extends StatelessWidget {
  final Novel novel;
  const NovelDetail({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 6,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          NovelInfo(novel: novel),
          NovelPageComponent(novel: novel),
          ReadedComponent(novel: novel),
          ExpandableTags(list: novel.meta.tags),
          novel.meta.tags.isNotEmpty ? Divider() : SizedBox.shrink(),
          SelectableText(novel.meta.desc),
        ],
      ),
    );
  }
}
