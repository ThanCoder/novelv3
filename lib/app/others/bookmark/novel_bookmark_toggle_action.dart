import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_provider.dart';
import 'package:provider/provider.dart';

class NovelBookmarkToggleAction extends StatelessWidget {
  final String novelTitle;
  const NovelBookmarkToggleAction({super.key, required this.novelTitle});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NovelBookmarkProvider>();
    return IconButton(
      onPressed: () {
        context.read<NovelBookmarkProvider>().toggle(
          NovelBookmark(title: novelTitle),
          context: context,
        );
      },
      icon: provider.isExists(novelTitle)
          ? Icon(Icons.bookmark_remove, color: Colors.red)
          : Icon(Icons.bookmark_add, color: Colors.blue),
    );
  }
}
