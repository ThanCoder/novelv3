import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/chapter_list_item.dart';
import 'package:novel_v3/app/models/text_reader_config_model.dart';
import 'package:novel_v3/app/provider/chapter_provider.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/screens/text_reader_screen.dart';
import 'package:novel_v3/app/widgets/index.dart';
import 'package:provider/provider.dart';

class ContentChapterPage extends StatefulWidget {
  const ContentChapterPage({super.key});

  @override
  State<ContentChapterPage> createState() => _ContentChapterPageState();
}

class _ContentChapterPageState extends State<ContentChapterPage> {
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
        .initList(novelPath: novel.path, isReset: true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChapterProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Chapter'),
      ),
      body: isLoading
          ? TLoader()
          : ListView.separated(
              itemBuilder: (context, index) => ChapterListItem(
                chapter: list[index],
                onClicked: (chapter) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TextReaderScreen(
                        chapter: chapter,
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
