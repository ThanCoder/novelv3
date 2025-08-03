import 'package:flutter/material.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';

import '../novel_v3_uploader.dart';
import 'helper_content_screen.dart';
import 'novel_content_screen.dart';
import 'see_all_screen.dart';
import 'uploader_novel_search_screen.dart';

class NovelV3UploaderHomeScreen extends StatefulWidget {
  const NovelV3UploaderHomeScreen({super.key});

  @override
  State<NovelV3UploaderHomeScreen> createState() =>
      _NovelV3UploaderHomeScreenState();
}

class _NovelV3UploaderHomeScreenState extends State<NovelV3UploaderHomeScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((e) => init());
    super.initState();
  }

  bool isLoading = false;
  bool isListView = false;
  List<UploaderNovel> list = [];
  List<HelperFile> helperList = [];

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      list = await OnlineNovelServices.getNovelList();
      helperList = await HelperServices.getOnlineList();
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Static Server'),
        actions: [
          // config app bar
          ...NovelV3Uploader.instance.appBarActions,
          IconButton(
            onPressed: _goSearchScreen,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              isListView = !isListView;
              setState(() {});
            },
            icon: Icon(isListView ? Icons.list : Icons.grid_on_sharp),
          ),
          // for desktop
          PlatformExtension.isDesktop()
              ? IconButton(onPressed: init, icon: Icon(Icons.refresh))
              : SizedBox.shrink(),
        ],
      ),
      body: isLoading
          ? Center(child: TLoaderRandom())
          : RefreshIndicator.adaptive(
              onRefresh: init,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _onListStyleChanger(),
              ),
            ),
    );
  }

  void _goContentPage(UploaderNovel novel) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NovelContentScreen(novel: novel)),
    );
  }

  void _goSeeAllScreen(String title, List<UploaderNovel> list) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeeAllScreen(
          title: Text(title),
          list: list,
          gridItemBuilder: (context, item) =>
              OnlineNovelGridItem(novel: item, onClicked: _goContentPage),
        ),
      ),
    );
  }

  void _goSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploaderNovelSearchScreen(
          list: list,
          listItemBuilder: (context, novel) =>
              OnlineNovelListItem(novel: novel, onClicked: _goContentPage),
          onClicked: (title, resList) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeeAllScreen<UploaderNovel>(
                  title: Text(title),
                  list: resList,
                  gridItemBuilder: (context, item) => OnlineNovelGridItem(
                    novel: item,
                    onClicked: _goContentPage,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getListWidget() {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) =>
          OnlineNovelListItem(novel: list[index], onClicked: _goContentPage),
    );
  }

  Widget _getGridWidget() {
    final completedList = list.where((e) => e.isCompleted).toList();
    final ongoingList = list.where((e) => !e.isCompleted).toList();
    final adultList = list.where((e) => e.isAdult).toList();
    final randomList = List.of(list);
    randomList.shuffle();

    return CustomScrollView(
      slivers: [
        // helper
        SliverToBoxAdapter(
          child: HelperSeeAllView(
            title: 'အကူအညီများ',
            titleColor: Colors.lime,
            list: helperList,
            showLines: 1,
            onSeeAllClicked: (title, list) {},
            onClicked: (helper) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HelperContentScreen(helper: helper),
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),

        SliverToBoxAdapter(
          child: OnlineNovelSeeAllView(
            title: 'ကျပန်း စာစဥ်များ',
            titleColor: Colors.lime,
            list: randomList,
            showLines: 1,
            onSeeAllClicked: _goSeeAllScreen,
            onClicked: _goContentPage,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),

        SliverToBoxAdapter(
          child: OnlineNovelSeeAllView(
            title: 'အသစ်များ',
            titleColor: Colors.green,
            list: list,
            onSeeAllClicked: _goSeeAllScreen,
            onClicked: _goContentPage,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: OnlineNovelSeeAllView(
            title: 'ပြီးဆုံး',
            titleColor: Colors.blue,
            list: completedList,
            onSeeAllClicked: _goSeeAllScreen,
            onClicked: _goContentPage,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: OnlineNovelSeeAllView(
            title: 'ဘာသာပြန်နေဆဲ',
            titleColor: Colors.amber,
            list: ongoingList,
            onSeeAllClicked: _goSeeAllScreen,
            onClicked: _goContentPage,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: OnlineNovelSeeAllView(
            titleColor: Colors.red,
            title: '18 နှစ်အထက်',
            list: adultList,
            onSeeAllClicked: _goSeeAllScreen,
            onClicked: _goContentPage,
          ),
        ),
      ],
    );
  }

  Widget _onListStyleChanger() {
    if (isListView) {
      return _getListWidget();
    }
    return _getGridWidget();
  }
}
