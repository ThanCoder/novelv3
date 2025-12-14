import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/types/home_page_list_style_type.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_provider.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/components/novel_grid_item.dart';
import 'package:novel_v3/app/ui/components/novel_list_item.dart';
import 'package:novel_v3/app/ui/components/sort_dialog_action.dart';
import 'package:novel_v3/app/ui/content/content_screen.dart';
import 'package:novel_v3/app/ui/home/home_menu_actions.dart';
import 'package:novel_v3/app/ui/home/novel_item_menu_actions.dart';
import 'package:novel_v3/app/ui/home/novel_sliver_tags_bar.dart';
import 'package:novel_v3/app/ui/search/search_screen.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:provider/provider.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  String? currentTag;
  // filter
  List<Novel> filterdNovelList = [];

  Future<void> init({bool isUsedCache = true}) async {
    context.read<NovelBookmarkProvider>().init();
    if (!mounted) return;
    await context.read<NovelProvider>().init(isUsedCache: isUsedCache);
  }

  NovelProvider get getWProvider => context.watch<NovelProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Setting.instance.appName),
        actions: [
          // sort
          SortDialogAction(
            isAsc: getWProvider.sortAsc,
            currentId: getWProvider.currentSortId,
            sortList: getWProvider.sortList,
            sortDialogCallback: (id, isAsc) {
              context.read<NovelProvider>().sort(id, isAsc);
            },
          ),
          IconButton(onPressed: _goSearchScreen, icon: Icon(Icons.search)),
          !TPlatform.isDesktop
              ? SizedBox.shrink()
              : IconButton(
                  onPressed: () => init(isUsedCache: false),
                  icon: Icon(Icons.refresh),
                ),
          HomeMenuActions(),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // _getAppbar(),
          NovelSliverTagsBar(value: currentTag, onChoosed: _onChoosedTag),
        ],
        body: getWProvider.isLoading
            ? Center(child: TLoader.random())
            : RefreshIndicator.adaptive(
                onRefresh: () async => init(isUsedCache: false),
                child: CustomScrollView(slivers: [_getListWidget()]),
              ),
      ),
    );
  }

  Widget _getEmptyWidget() {
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

  Widget _getListWidget() {
    if (getWProvider.list.isEmpty) {
      return _getEmptyWidget();
    }
    // bookmark
    if (currentTag != null && currentTag == 'BookMark') {
      final bookmarkProvider = context.watch<NovelBookmarkProvider>();
      if (bookmarkProvider.isLoading) {
        return SliverFillRemaining(child: Center(child: TLoader.random()));
      }
      return _getListStyleWidget(bookmarkProvider.novelList);
    }
    // latest
    if (currentTag != null && currentTag != novelSliverTags.first) {
      if (filterdNovelList.isEmpty) {
        return _getEmptyWidget();
      }
      return _getListStyleWidget(filterdNovelList);
    }

    return _getListStyleWidget(getWProvider.list);
  }

  Widget _getListStyleWidget(List<Novel> list) {
    return ValueListenableBuilder(
      valueListenable: homePageListStyleNotifier,
      builder: (context, listStyle, child) {
        if (listStyle == ListStyleType.grid) {
          return SliverGrid.builder(
            itemCount: list.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 170,
              mainAxisExtent: 190,
              // mainAxisSpacing: 1,
              // crossAxisSpacing: 1,
            ),
            itemBuilder: (context, index) => NovelGridItem(
              novel: list[index],
              onClicked: _goContentScreen,
              onRightClicked: _onItemMenu,
            ),
          );
        }
        return SliverList.builder(
          itemCount: list.length,
          itemBuilder: (context, index) => _getListItem(list[index]),
        );
      },
    );
  }

  Widget _getListItem(Novel novel) {
    return NovelListItem(
      novel: novel,
      onClicked: _goContentScreen,
      onRightClicked: _onItemMenu,
    );
  }

  // filter tags
  void _onChoosedTag(String tag) async {
    currentTag = tag;

    final list = context.read<NovelProvider>().list;
    if (tag == 'BookMark') {
      setState(() {});
      await context.read<NovelBookmarkProvider>().parseNovelList();
    } else {
      filterdNovelList = list.where((e) {
        if (tag == 'Completed' && e.meta.isCompleted) {
          return true;
        }
        if (tag == 'OnGoing' && !e.meta.isCompleted) {
          return true;
        }
        if (tag == 'No Adult' && !e.meta.isAdult) {
          return true;
        }
        if (tag == 'Adult' && e.meta.isAdult) {
          return true;
        }
        return false;
      }).toList();
      setState(() {});
    }
  }

  // item menu
  void _onItemMenu(Novel novel) {
    showTMenuBottomSheetSingle(
      context,
      title: Text(novel.title),
      child: NovelItemMenuActions(novel: novel),
    );
  }

  void _goContentScreen(Novel novel) async {
    await context.read<NovelProvider>().setCurrentNovel(novel);
    if (!mounted) return;
    goRoute(context, builder: (context) => ContentScreen());
  }

  void _goSearchScreen() {
    goRoute(context, builder: (context) => SearchScreen());
  }
}
