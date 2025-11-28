import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/core/providers/chapter_provider.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/others/chapter_reader/chapter_reader_config.dart';
import 'package:novel_v3/app/others/chapter_reader/chapter_reader_screen.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class ChapterPage extends StatefulWidget {
  const ChapterPage({super.key});

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    final novelPath = context.read<NovelProvider>().currentNovel!.path;
    context.read<ChapterProvider>().init(novelPath);
  }

  ChapterProvider get getProvider => context.watch<ChapterProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getProvider.isLoading
          ? Center(child: TLoader.random())
          : CustomScrollView(slivers: [_getList()]),
    );
  }

  Widget _getList() {
    return SliverList.builder(
      itemCount: getProvider.list.length,
      itemBuilder: (context, index) => _getListItem(getProvider.list[index]),
    );
  }

  Widget _getListItem(Chapter chapter) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.article),
        title: Text('${chapter.number}: ${chapter.title}', maxLines: 1),
        // trailing: Icon(Icons.bookmark),
        onTap: () {
          goRoute(
            context,
            builder: (context) => ChapterReaderScreen(
              chapter: chapter,
              config: ChapterReaderConfig.create(),
            ),
          );
        },
      ),
    );
  }
}
