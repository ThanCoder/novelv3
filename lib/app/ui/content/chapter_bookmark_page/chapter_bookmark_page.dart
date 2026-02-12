import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/chapter_bookmark.dart';
import 'package:novel_v3/core/providers/chapter_bookmark_provider.dart';
import 'package:novel_v3/core/providers/novel_provider.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/content/chapter_bookmark_page/chapter_bookmark_list_item.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ChapterBookmarkPage extends StatefulWidget {
  const ChapterBookmarkPage({super.key});

  @override
  State<ChapterBookmarkPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterBookmarkPage> {
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    novelPath = context.read<NovelProvider>().currentNovel!.path;
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  late String novelPath;

  Future<void> init() async {
    await context.read<ChapterBookmarkProvider>().init(novelPath);
  }

  ChapterBookmarkProvider get getProvider =>
      context.watch<ChapterBookmarkProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getProvider.isLoading
          ? Center(child: TLoader.random())
          : RefreshIndicator.adaptive(
              onRefresh: init,
              child: CustomScrollView(
                controller: controller,
                slivers: [_getAppbar(), _getList()],
              ),
            ),
    );
  }

  Widget _getAppbar() {
    if (!TPlatform.isDesktop) {
      return SliverToBoxAdapter();
    }
    return SliverAppBar(
      automaticallyImplyLeading: false,
      actions: [IconButton(onPressed: init, icon: Icon(Icons.refresh))],
    );
  }

  Widget _getList() {
    if (getProvider.list.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 3,
            children: [
              Text('List Empty!...', style: TextTheme.of(context).labelLarge),
              IconButton(
                onPressed: init,
                icon: Icon(Icons.refresh, color: Colors.blue),
              ),
            ],
          ),
        ),
      );
    }
    return SliverList.builder(
      itemCount: getProvider.list.length,
      itemBuilder: (context, index) => ChapterBookmarkListItem(
        bookmark: (getProvider.list[index]),
        onClicked: _goReaderPage,
      ),
    );
  }

  void _goReaderPage(ChapterBookmark bookmark) {
    final chapter = Chapter.create(
      number: bookmark.chapter,
      title: bookmark.title,
    );

    goChapterReader(context, chapter: chapter);
  }
}
