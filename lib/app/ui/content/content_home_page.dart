import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:provider/provider.dart';

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
              child: Text(novel.meta.desc, style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
