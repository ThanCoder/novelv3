import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/provider/novel_bookmark_provider.dart';
import 'package:provider/provider.dart';

class NovelBookmarkButton extends StatefulWidget {
  NovelModel novel;
  NovelBookmarkButton({super.key, required this.novel});

  @override
  State<NovelBookmarkButton> createState() => _NovelBookmarkButtonState();
}

class _NovelBookmarkButtonState extends State<NovelBookmarkButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  void init() async {
    final provider = context.read<NovelBookmarkProvider>();
    await provider.initList();
    provider.checkExists(widget.novel);
  }

  void _toggle() {
    context.read<NovelBookmarkProvider>().toggle(widget.novel);
  }

  @override
  Widget build(BuildContext context) {
    final isExists = context.watch<NovelBookmarkProvider>().isExists;
    return IconButton(
      color: isExists ? Colors.red : Colors.teal,
      onPressed: _toggle,
      icon: Icon(
        isExists ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded,
      ),
    );
  }
}
