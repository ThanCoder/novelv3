import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/ui/components/see_all_screen.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/ui/helper/helper_content_screen.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/ui/novel/novel_content_ui_switcher.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/ui/uploader_file/uploader_file_history_list.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../novel_v3_uploader.dart';
import 'components/index.dart';
import 'novel/uploader_novel_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((e) => init());
    super.initState();
  }

  bool isLoading = false;
  bool isListView = false;
  bool isInternetConnected = false;
  List<Novel> list = [];
  List<HelperFile> helperList = [];

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      isInternetConnected = await ThanPkg.platform.isInternetConnected();
      if (!isInternetConnected) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      list = await NovelServices.getOnlineList();
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
        title: Text(NovelV3Uploader.appLabelText),
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
            icon: Icon(isListView ? Icons.list : Icons.grid_view_outlined),
          ),
          // for desktop
          TPlatform.isDesktop
              ? IconButton(onPressed: init, icon: Icon(Icons.refresh))
              : SizedBox.shrink(),
        ],
      ),
      body: isLoading
          ? Center(child: TLoader.random())
          :
            // check internet
            !isInternetConnected
          ? Center(
              child: Text('Your Offline!', style: TextStyle(color: Colors.red)),
            )
          : RefreshIndicator.adaptive(
              onRefresh: init,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _onListStyleChanger(),
              ),
            ),
    );
  }

  void _goContentPage(Novel novel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelContentUiSwitcher(novel: novel),
      ),
    );
  }

  void _goSeeAllScreen(String title, List<Novel> list) {
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
        builder: (context) => NovelSearchScreen(
          list: list,
          listItemBuilder: (context, novel) =>
              OnlineNovelListItem(novel: novel, onClicked: _goContentPage),
          onClicked: (title, resList) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeeAllScreen<Novel>(
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

        // uploader file history list
        SliverToBoxAdapter(
          child: UploaderFileHistoryPage(
            isApiList: true,
            onClicked: _onParseAndGoContentPage,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),

        SliverToBoxAdapter(
          child: OnlineNovelSeeAllView(
            title: 'အသစ်များ',
            // titleColor: Colors.green,
            list: list,
            onSeeAllClicked: _goSeeAllScreen,
            onClicked: _goContentPage,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: OnlineNovelSeeAllView(
            title: 'ပြီးဆုံး',
            // titleColor: Colors.blue,
            list: completedList,
            onSeeAllClicked: _goSeeAllScreen,
            onClicked: _goContentPage,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: OnlineNovelSeeAllView(
            title: 'ဘာသာပြန်နေဆဲ',
            // titleColor: Colors.amber,
            list: ongoingList,
            onSeeAllClicked: _goSeeAllScreen,
            onClicked: _goContentPage,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),
        // Random
        SliverToBoxAdapter(
          child: OnlineNovelSeeAllView(
            title: 'ကျပန်း စာစဥ်များ',
            // titleColor: Colors.lime,
            list: randomList,
            showLines: 1,
            onSeeAllClicked: _goSeeAllScreen,
            onClicked: _goContentPage,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: OnlineNovelSeeAllView(
            // titleColor: Colors.red,
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

  void _onParseAndGoContentPage(UploaderFile file) async {
    final novel = await NovelServices.getApiDatabase.getById(file.novelId);
    if (!mounted) return;
    if (novel == null) {
      showTMessageDialogError(context, 'Novel မရှိပါ!');
      return;
    }
    _goContentPage(novel);
  }
}
