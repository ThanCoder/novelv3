import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/chapter_book_list_item.dart';
import 'package:novel_v3/my_libs/text_reader/chapter_bookmark_model.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/screens/content/background_scaffold.dart';
import 'package:novel_v3/my_libs/t_history_v1.0.0/index.dart';
import 'package:novel_v3/my_libs/text_reader/add_bookmark_title_dialog.dart';
import 'package:t_widgets/t_widgets.dart';
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
    final currentChapter = bookmark.toChapter(novel.path);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddBookmarkTitleDialog(
        submitText: 'ပြောင်းလဲ',
        chapter: currentChapter,
        readLine: globalReadLine,
        onSubmit: (title, readLine) async {
          globalReadLine = readLine;
          bookmark.title = title;
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
    //set history
    THistoryServices.instance.add(THistoryRecord.create(
      title: bookmark.title,
      method: TMethods.delete,
      desc: 'BookMark Deleted',
    ));
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
    return BackgroundScaffold(
      stackChildren: [
        isLoading
            ? Center(child: TLoaderRandom())
            : RefreshIndicator(
                onRefresh: init,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: const Color.fromARGB(0, 97, 97, 97),
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
                    SliverList.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: list.length,
                      itemBuilder: (context, index) => ChapterBookListItem(
                        book: list[index],
                        onClicked: (book) {
                          final novel = ref
                              .read(novelNotifierProvider.notifier)
                              .getCurrent;
                          if (novel == null) return;
                          goTextReader(
                              context, ref, book.toChapter(novel.path));
                        },
                        onLongClicked: _showMenu,
                      ),
                    )
                  ],
                ),
              ),
      ],
    );
  }
}
