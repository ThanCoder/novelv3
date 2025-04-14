import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_see_all_view.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/provider/novel_bookmark_provider.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/provider/recent_provider.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/screens/novel_see_all_screen.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../widgets/index.dart';

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

  Future<void> init() async {
    context.read<NovelProvider>().initList();
    context.read<NovelBookmarkProvider>().initList();
    context.read<RecentProvider>().initList();
  }

  void _goShowAllScreen(String title, List<NovelModel> list) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelSeeAllScreen(title: title, list: list),
      ),
    );
  }

  void _goContentScreen(NovelModel novel) {
    goNovelContentPage(context, novel);
  }

  Widget _getListWidget(List<NovelModel> list) {
    final randomList = List.of(list);
    randomList.shuffle();

    final bookList = context.watch<NovelBookmarkProvider>().getList;
    final recentList = context.watch<RecentProvider>().getList;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text(appTitle),
          snap: true,
          floating: true,
          actions: [
            PlatformExtension.isDesktop()
                ? IconButton(
                    onPressed: () {
                      context.read<NovelProvider>().initList(isReset: true);
                    },
                    icon: const Icon(Icons.refresh),
                  )
                : const SizedBox.shrink(),
          ],
        ),

        // Recent
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'မကြာခင်က',
            list: recentList,
            onSeeAllClicked: _goShowAllScreen,
            onClicked: _goContentScreen,
          ),
        ),
        // Random
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'ကျပန်း',
            list: randomList,
            onSeeAllClicked: _goShowAllScreen,
            onClicked: _goContentScreen,
          ),
        ),
        // latest
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'နောက်ဆုံး',
            list: list,
            onSeeAllClicked: _goShowAllScreen,
            onClicked: _goContentScreen,
          ),
        ),
        // Completed
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'ပြီးဆုံး',
            list: list.where((nv) => nv.isCompleted).toList(),
            onSeeAllClicked: _goShowAllScreen,
            onClicked: _goContentScreen,
          ),
        ),
        // OnGoing
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'ဆက်သွားနေဆဲ',
            list: list.where((nv) => !nv.isCompleted).toList(),
            onSeeAllClicked: _goShowAllScreen,
            onClicked: _goContentScreen,
          ),
        ),
        // Adult
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'Adult',
            list: list.where((nv) => nv.isAdult).toList(),
            onSeeAllClicked: _goShowAllScreen,
            onClicked: _goContentScreen,
          ),
        ),

        // Book Mark
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'Book Mark',
            list: bookList,
            onSeeAllClicked: _goShowAllScreen,
            onClicked: _goContentScreen,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NovelProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;
    return MyScaffold(
      contentPadding: 0,
      body: isLoading ? TLoader() : _getListWidget(list),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
