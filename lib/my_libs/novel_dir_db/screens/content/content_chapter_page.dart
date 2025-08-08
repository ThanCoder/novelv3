import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/widgets/t_loader_random.dart';
import 'package:than_pkg/extensions/index.dart';

import '../../novel_dir_db.dart';

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
    await context.read<ChapterProvider>().initList(novel.path);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChapterProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;
    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter'),
        automaticallyImplyLeading: PlatformExtension.isDesktop(),
      ),
      body: isLoading
          ? Center(child: TLoaderRandom())
          : list.isEmpty
              ? _getEmptyListWidget()
              : CustomScrollView(
                  slivers: [
                    _getSliverList(list),
                  ],
                ),
    );
  }

  Widget _getEmptyListWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('List မရှိပါ...'),
          IconButton(
              color: Colors.blue, onPressed: init, icon: Icon(Icons.refresh)),
        ],
      ),
    );
  }

  Widget _getSliverList(List<Chapter> list) {
    return SliverList.separated(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return ListTile(
          title: Row(
            spacing: 5,
            children: [
              Text('Ch: ${item.number}'),
              Text(
                item.getTitle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          onTap: () => NovelDirDb.instance.goTextReader(context,item),
        );
      },
      separatorBuilder: (context, index) => Divider(),
    );
  }
}
