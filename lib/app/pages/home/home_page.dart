import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_see_all_view.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
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

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text(appTitle),
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
        // Random
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'Random',
            list: randomList,
            onSeeAllClicked: _goShowAllScreen,
            onClicked: _goContentScreen,
          ),
        ),
        // latest
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'Latest',
            list: list,
            onSeeAllClicked: _goShowAllScreen,
            onClicked: _goContentScreen,
          ),
        ),
        // Completed
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'Completed',
            list: list.where((nv) => nv.isCompleted).toList(),
            onSeeAllClicked: _goShowAllScreen,
            onClicked: _goContentScreen,
          ),
        ),
        // OnGoing
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'OnGoing',
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NovelProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;
    return MyScaffold(
      body: isLoading ? TLoader() : _getListWidget(list),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
