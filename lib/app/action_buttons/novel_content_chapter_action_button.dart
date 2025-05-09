import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/screens/chapter_online_fetcher_screen.dart';
import 'package:novel_v3/app/screens/chapter_edit_form.dart';

class NovelContentChapterActionButton extends ConsumerStatefulWidget {
  VoidCallback? onBackpress;
  NovelContentChapterActionButton({super.key, this.onBackpress});

  @override
  ConsumerState<NovelContentChapterActionButton> createState() =>
      _NovelContentChapterActionButtonState();
}

class _NovelContentChapterActionButtonState
    extends ConsumerState<NovelContentChapterActionButton> {
  void _addChapterFromOnline() async {
    final provider = ref.read(novelNotifierProvider.notifier);
    final novel = provider.getCurrent;
    if (novel == null) return;
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterOnlineFetcherScreen(
          novelPath: novel.path,
        ),
      ),
    );
  }

  void goChapterEditForm(BuildContext context) async {
    final provider = ref.read(novelNotifierProvider.notifier);
    final novel = provider.getCurrent;
    if (novel == null) return;
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterEditForm(novelPath: novel.path),
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 100,
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add Chapter'),
                onTap: () {
                  Navigator.pop(context);
                  goChapterEditForm(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add Chapter From Online'),
                onTap: () {
                  Navigator.pop(context);
                  _addChapterFromOnline();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showMenu,
      icon: const Icon(Icons.more_vert),
    );
  }
}
