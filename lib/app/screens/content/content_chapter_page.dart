import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/chapter_list_item.dart';
import 'package:provider/provider.dart';
import 'package:than_pkg/extensions/index.dart';

import '../../novel_dir_app.dart';
import 'content_image_wrapper.dart';

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

    return ContentImageWrapper(
      title: Text('Chapter'),
      isLoading: isLoading,
      automaticallyImplyLeading: PlatformExtension.isDesktop(),
      sliverBuilder: (context, novel) => [_getSliverList(list)],
      onRefresh: init,
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
            color: Colors.blue,
            onPressed: init,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _getSliverList(List<Chapter> list) {
    if (list.isEmpty) {
      return SliverToBoxAdapter(child: _getEmptyListWidget());
    }
    return SliverList.separated(
      itemCount: list.length,
      itemBuilder: (context, index) => ChapterListItem(
        chapter: list[index],
        onClicked: (chapter) =>
            NovelDirApp.instance.goTextReader(context, chapter),
      ),
      separatorBuilder: (context, index) => Divider(),
    );
  }
}
