import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/core/providers/chapter_provider.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/components/sort_dialog_action.dart';
import 'package:novel_v3/app/ui/content/chapter_list_item.dart';
import 'package:novel_v3/app/ui/content/chapter_menu_actions.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ChapterPage extends StatefulWidget {
  const ChapterPage({super.key});

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
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

  String? novelPath;
  Future<void> init({bool isUsedCache = true}) async {
    novelPath = context.read<NovelProvider>().currentNovel!.path;
    await context.read<ChapterProvider>().init(
      novelPath!,
      isUsedCache: isUsedCache,
    );
    setState(() {});
  }

  ChapterProvider get getWProvider => context.watch<ChapterProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getWProvider.isLoading
          ? Center(child: TLoader.random())
          : RefreshIndicator.adaptive(
              onRefresh: () async => init(isUsedCache: false),
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
      title: _getRecentName() == ''
          ? null
          : TextButton(
              onPressed: _goRecentChapter,
              child: Text('Recent Chapter: ${_getRecentName()}'),
            ),
      actions: [
        Text('Count: ${getWProvider.list.length}'),
        !TPlatform.isDesktop
            ? SizedBox.shrink()
            : IconButton(
                onPressed: () => init(isUsedCache: false),
                icon: Icon(Icons.refresh),
              ),
        // sort
        SortDialogAction(
          isAsc: getWProvider.sortAsc,
          currentId: getWProvider.currentSortId,
          sortList: getWProvider.sortList,
          sortDialogCallback: (id, isAsc) {
            context.read<ChapterProvider>().sort(id, isAsc);
          },
        ),
        ChapterMenuActions(),
      ],
    );
  }

  Widget _getList() {
    if (getWProvider.list.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 3,
            children: [
              Text('List Empty!...', style: TextTheme.of(context).labelLarge),
              IconButton(
                onPressed: () => init(isUsedCache: false),
                icon: Icon(Icons.refresh, color: Colors.blue),
              ),
            ],
          ),
        ),
      );
    }
    return SliverList.builder(
      itemCount: getWProvider.list.length,
      itemBuilder: (context, index) => ChapterListItem(
        chapter: (getWProvider.list[index]),
        onClicked: _goReaderPage,
      ),
    );
  }

  // recent
  String _getRecentName() {
    if (novelPath != null) {
      final recent = TRecentDB.getInstance.getString(
        'recent-chapter-name:${novelPath!.getName()}',
      );
      if (recent.isEmpty) return '';
      return recent;
    }
    return '';
  }

  void _goRecentChapter() async {
    final list = context.read<ChapterProvider>().list;
    final index = list.indexWhere(
      (e) => e.number.toString() == _getRecentName(),
    );
    if (index == -1) {
      TRecentDB.getInstance.delete(
        'recent-chapter-name:${novelPath!.getName()}',
      );
      setState(() {});
      return;
    }
    _goReaderPage(list[index]);
  }

  void _goReaderPage(Chapter chapter) async {
    goChapterReader(context, chapter: chapter);
  }
}
