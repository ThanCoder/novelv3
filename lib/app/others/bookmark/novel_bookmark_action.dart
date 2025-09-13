import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_db.dart';
import 'package:novel_v3/app/novel_dir_app.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/widgets/index.dart';

class NovelBookmarkAction extends StatefulWidget {
  const NovelBookmarkAction({super.key});

  @override
  State<NovelBookmarkAction> createState() => _NovelBookmarkActionState();
}

class _NovelBookmarkActionState extends State<NovelBookmarkAction> {
  @override
  Widget build(BuildContext context) {
    final novel = context.watch<NovelProvider>().getCurrent;
    if (novel == null) return SizedBox.shrink();
    return FutureBuilder(
      future: NovelBookmarkDB.getInstance().getNovelList(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return TLoader(size: 20);
        }
        if (!asyncSnapshot.hasData) {
          return SizedBox.shrink();
        }
        final list = asyncSnapshot.data ?? [];
        final index = list.indexWhere((e) => e.title == novel.title);
        final isExists = index != -1;
        return IconButton(
          onPressed: _toggle,
          icon: Icon(
            color: isExists ? Colors.red : Colors.teal,
            isExists
                ? Icons.bookmark_remove_rounded
                : Icons.bookmark_add_rounded,
          ),
        );
      },
    );
  }

  void _toggle() async {
    final novel = context.read<NovelProvider>().getCurrent!;
    await NovelBookmarkDB.getInstance().toggleNovel(novel);
    if (!mounted) return;
    setState(() {});
    context.read<NovelProvider>().refreshNotifier();
  }
}
