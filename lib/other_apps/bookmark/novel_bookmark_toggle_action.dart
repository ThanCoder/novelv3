import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/other_apps/bookmark/novel_bookmark.dart';
import 'package:novel_v3/other_apps/bookmark/novel_bookmark_provider.dart';
import 'package:provider/provider.dart';

class NovelBookmarkToggleAction extends StatelessWidget {
  final Novel novel;
  const NovelBookmarkToggleAction({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NovelBookmarkProvider>();
    return IconButton(
      onPressed: () {
        context.read<NovelBookmarkProvider>().toggle(
          NovelBookmark(id: novel.id, title: novel.meta.title),
          context: context,
        );
      },
      icon: provider.isExists(novel.id)
          ? Icon(Icons.bookmark_remove, color: Colors.red)
          : Icon(Icons.bookmark_add, color: Colors.blue),
    );
  }
}
