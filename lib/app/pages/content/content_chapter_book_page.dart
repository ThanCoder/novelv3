import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/chapter_book_list_item.dart';
import 'package:novel_v3/app/dialogs/core/index.dart';
import 'package:novel_v3/app/models/chapter_bookmark_model.dart';
import 'package:novel_v3/app/provider/chapter_bookmark_provider.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/widgets/index.dart';
import 'package:provider/provider.dart';

class ContentChapterBookPage extends StatefulWidget {
  const ContentChapterBookPage({super.key});

  @override
  State<ContentChapterBookPage> createState() => _ContentChapterBookPageState();
}

class _ContentChapterBookPageState extends State<ContentChapterBookPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    context.read<ChapterBookmarkProvider>().initList(novel.path);
  }

  void _showEdit(ChapterBookmarkModel bookmark) {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    showDialog(
      context: context,
      builder: (context) => RenameDialog(
        title: 'Edit Title',
        text: bookmark.title,
        onSubmit: (text) {
          if (text.isEmpty) return;
          bookmark.title = text;
          context.read<ChapterBookmarkProvider>().update(novel.path, bookmark);
        },
      ),
    );
  }

  void _delete(ChapterBookmarkModel bookmark) {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    context.read<ChapterBookmarkProvider>().remove(novel.path, bookmark);
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChapterBookmarkProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Book Mark'),
      ),
      body: isLoading
          ? TLoader()
          : ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: list.length,
              itemBuilder: (context, index) => ChapterBookListItem(
                book: list[index],
                onClicked: (book) {
                  final novel = context.read<NovelProvider>().getCurrent;
                  if (novel == null) return;
                  goTextReader(context, book.toChapter(novel.path));
                },
                onLongClicked: _showMenu,
              ),
            ),
    );
  }
}
