import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/components/novel_list_item.dart';
import 'package:novel_v3/app/ui/content/content_screen.dart';
import 'package:provider/provider.dart';

class SearchResultScreen extends StatefulWidget {
  final String title;
  const SearchResultScreen({super.key, required this.title});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: CustomScrollView(slivers: [_getListWidget()]),
    );
  }

  Widget _getListWidget() {
    final list = context.watch<NovelProvider>().searchResultList;
    return SliverList.builder(
      itemCount: list.length,
      itemBuilder: (context, index) =>
          NovelListItem(novel: list[index], onClicked: _goNovelContentPage),
    );
  }

  void _goNovelContentPage(Novel novel) async {
    await context.read<NovelProvider>().setCurrentNovel(novel);
    if (!mounted) return;
    goRoute(context, builder: (context) => ContentScreen());
  }
}
