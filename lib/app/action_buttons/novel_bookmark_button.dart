import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/riverpods/providers.dart';

class NovelBookmarkButton extends ConsumerStatefulWidget {
  NovelModel novel;
  NovelBookmarkButton({super.key, required this.novel});

  @override
  ConsumerState<NovelBookmarkButton> createState() =>
      _NovelBookmarkButtonState();
}

class _NovelBookmarkButtonState extends ConsumerState<NovelBookmarkButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  void init() async {
    final provider = ref.read(bookmarkNotifierProvider.notifier);
    await provider.initList();
    provider.checkExists(widget.novel);
  }

  void _toggle() {
   ref.read(bookmarkNotifierProvider.notifier).toggle(widget.novel);
  }

  @override
  Widget build(BuildContext context) {
    final isExists = ref.watch(bookmarkNotifierProvider).isExists;
    return IconButton(
      color: isExists ? Colors.red : Colors.teal,
      onPressed: _toggle,
      icon: Icon(
        isExists ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded,
      ),
    );
  }
}
