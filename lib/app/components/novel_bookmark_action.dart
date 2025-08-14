import 'package:flutter/material.dart';
import 'package:novel_v3/app/novel_dir_app.dart';
import 'package:novel_v3/app/providers/novel_bookmark_provider.dart';
import 'package:novel_v3/app/services/novel_bookmark_services.dart';
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
      future: NovelBookmarkServices.isExists(novel.title),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return TLoader(size: 20);
        }
        if (!asyncSnapshot.hasData) {
          return SizedBox.shrink();
        }
        final isExists = asyncSnapshot.data ?? false;
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
    await NovelBookmarkServices.toggle(novel.title);
    if (!mounted) return;
    context.read<NovelBookmarkProvider>().initList();
    setState(() {});
  }
}
