import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/core/models/chapter_bookmark.dart';
import 'package:novel_v3/app/core/providers/chapter_bookmark_provider.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/others/chapter_reader/chapter_reader_config.dart';
import 'package:novel_v3/app/others/chapter_reader/chapter_reader_screen.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/content/chapter_bookmark_list_item.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> init() async {
    final novelPath = context.read<NovelProvider>().currentNovel!.path;
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
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: false,
      floating: true,
      snap: true,
      actions: [
        !TPlatform.isDesktop
            ? SizedBox.shrink()
            : IconButton(onPressed: init, icon: Icon(Icons.refresh)),
      ],
    );
  }

  Widget _getList() {
    if (getProvider.list.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'List Empty!...',
            style: TextTheme.of(context).headlineMedium,
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

    final configPath = PathUtil.getConfigPath(name: 'chapter.config.json');
    goRoute(
      context,
      builder: (context) => ChapterReaderScreen(
        chapter: chapter,
        config: ChapterReaderConfig.fromPath(configPath),
        onUpdateConfig: (updatedConfig) {
          updatedConfig.savePath(configPath);
        },
      ),
    );
  }
}
