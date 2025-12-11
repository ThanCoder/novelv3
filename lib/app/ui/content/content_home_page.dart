import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class ContentHomePage extends StatelessWidget {
  const ContentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final novel = context.watch<NovelProvider>().currentNovel!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  // tag
                  TTagsWrapView(values: novel.meta.tags, type: TTagsTypes.text),
                  novel.meta.tags.isNotEmpty ? Divider() : SizedBox.shrink(),
                  SelectableText(
                    novel.meta.desc,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
