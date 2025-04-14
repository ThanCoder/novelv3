import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/chapter_book_list_item.dart';
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
              itemBuilder: (context, index) => ChapterBookListItem(
                book: list[index],
                onClicked: (book) {
                  final novel = context.read<NovelProvider>().getCurrent;
                  if (novel == null) return;
                  goTextReader(context, book.toChapter(novel.path));
                },
              ),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: list.length,
            ),
    );
  }
}
