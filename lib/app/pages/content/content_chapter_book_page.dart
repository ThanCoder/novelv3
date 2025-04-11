import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/chapter_book_list_item.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/models/text_reader_config_model.dart';
import 'package:novel_v3/app/provider/chapter_provider.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/screens/text_reader_screen.dart';
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
    context
        .read<ChapterProvider>()
        .initBookList(bookPath: novel.chapterBookmarkPath, isReset: true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChapterProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getBookList;
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TextReaderScreen(
                        chapter: ChapterModel.fromPath(
                            '${provider.getNovelPath}/${book.chapter}'),
                        config: TextReaderConfigModel(),
                      ),
                    ),
                  );
                },
              ),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: list.length,
            ),
    );
  }
}
