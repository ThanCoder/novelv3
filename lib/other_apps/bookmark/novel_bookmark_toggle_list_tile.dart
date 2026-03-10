import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/other_apps/bookmark/novel_bookmark.dart';
import 'package:novel_v3/other_apps/bookmark/novel_bookmark_provider.dart';
import 'package:provider/provider.dart';

class NovelBookmarkToggleListTile extends StatelessWidget {
  final Novel novel;
  final VoidCallback? onClosed;
  const NovelBookmarkToggleListTile({
    super.key,
    required this.novel,
    this.onClosed,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NovelBookmarkProvider>();
    return ListTile(
      leading: provider.isExists(novel.id)
          ? Icon(Icons.bookmark_remove, color: Colors.red)
          : Icon(Icons.bookmark_add, color: Colors.blue),
      title: provider.isExists(novel.id)
          ? Text('Remove Bookmark')
          : Text('Add Bookmark'),
      onTap: () {
        context.read<NovelBookmarkProvider>().toggle(
          NovelBookmark(id: novel.id, title: novel.meta.title),
          context: context,
        );
        onClosed?.call();
      },
    );
  }
}
