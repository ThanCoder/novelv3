import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/search/search_result_screen.dart';
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
                  novel.meta.originalTitle.isEmpty
                      ? SizedBox.shrink()
                      : Text(
                          'Original Title: ${novel.meta.originalTitle}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                  novel.meta.englishTitle.isEmpty
                      ? SizedBox.shrink()
                      : Text(
                          'English Title: ${novel.meta.englishTitle}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                  // tag
                  TTagsWrapView(
                    values: novel.meta.tags,
                    type: TTagsTypes.text,
                    onClicked: (value) {
                      final res = context.read<NovelProvider>().searchTag(
                        value,
                      );
                      goRoute(
                        context,
                        builder: (context) =>
                            SearchResultScreen(title: value, list: res),
                      );
                    },
                  ),
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
