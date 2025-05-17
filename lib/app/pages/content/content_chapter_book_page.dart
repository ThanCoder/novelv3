import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/chapter_book_list_item.dart';
import 'package:novel_v3/app/dialogs/core/index.dart';
import 'package:novel_v3/app/models/chapter_bookmark_model.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';

class ContentChapterBookPage extends ConsumerStatefulWidget {
  const ContentChapterBookPage({super.key});

  @override
  ConsumerState<ContentChapterBookPage> createState() =>
      _ContentChapterBookPageState();
}

class _ContentChapterBookPageState
    extends ConsumerState<ContentChapterBookPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    final novel = ref.read(novelNotifierProvider.notifier).getCurrent;
    if (novel == null) return;
    ref.read(chapterBookmarkNotifierProvider.notifier).initList(novel.path);
  }

  void _showEdit(ChapterBookmarkModel bookmark) {
    final novel = ref.read(novelNotifierProvider.notifier).getCurrent;
    if (novel == null) return;
    showDialog(
      context: context,
      builder: (context) => RenameDialog(
        title: 'Edit Title',
        text: bookmark.title,
        onSubmit: (text) {
          if (text.isEmpty) return;
          bookmark.title = text;
          ref
              .read(chapterBookmarkNotifierProvider.notifier)
              .update(novel.path, bookmark);
        },
      ),
    );
  }

  void _delete(ChapterBookmarkModel bookmark) {
    final novel = ref.read(novelNotifierProvider.notifier).getCurrent;
    if (novel == null) return;
    ref
        .read(chapterBookmarkNotifierProvider.notifier)
        .remove(novel.path, bookmark);
  }

  void _showMenu(ChapterBookmarkModel bookmark) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 150),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_document),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showEdit(bookmark);
                },
              ),
              ListTile(
                iconColor: Colors.yellow,
                leading: const Icon(Icons.delete_forever),
                title: const Text('Remove'),
                onTap: () {
                  Navigator.pop(context);
                  _delete(bookmark);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refersh() async {
    final novel = ref.read(novelNotifierProvider.notifier).getCurrent;
    if (novel == null) return;
    ref.read(chapterBookmarkNotifierProvider.notifier).initList(novel.path);
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(chapterBookmarkNotifierProvider);
    final isLoading = provider.isLoading;
    final list = provider.list;
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Book Mark'),
        actions: [
          PlatformExtension.isDesktop()
              ? IconButton(
                  onPressed: _refersh,
                  icon: const Icon(Icons.refresh),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: isLoading
          ? TLoader()
          : RefreshIndicator.noSpinner(
              onRefresh: _refersh,
              child: ListView.separated(
                separatorBuilder: (context, index) => const Divider(),
                itemCount: list.length,
                itemBuilder: (context, index) => ChapterBookListItem(
                  book: list[index],
                  onClicked: (book) {
                    final novel =
                        ref.read(novelNotifierProvider.notifier).getCurrent;
                    if (novel == null) return;
                    goTextReader(context, ref, book.toChapter(novel.path));
                  },
                  onLongClicked: _showMenu,
                ),
              ),
            ),
    );
  }
}
