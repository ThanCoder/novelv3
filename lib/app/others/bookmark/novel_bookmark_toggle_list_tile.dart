import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_provider.dart';
import 'package:provider/provider.dart';

class NovelBookmarkToggleListTile extends StatelessWidget {
  final String novelTitle;
  final VoidCallback? onClosed;
  const NovelBookmarkToggleListTile({
    super.key,
    required this.novelTitle,
    this.onClosed,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NovelBookmarkProvider>();
    return ListTile(
      leading: provider.isExists(novelTitle)
          ? Icon(Icons.bookmark_remove, color: Colors.red)
          : Icon(Icons.bookmark_add, color: Colors.blue),
      title: provider.isExists(novelTitle)
          ? Text('Remove Bookmark')
          : Text('Add Bookmark'),
      onTap: () {
        context.read<NovelBookmarkProvider>().toggle(
          NovelBookmark(title: novelTitle),
        );
        onClosed?.call();
      },
    );
  }
}
