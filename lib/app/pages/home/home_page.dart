import 'package:flutter/material.dart';
import 'package:novel_v3/app/action_buttons/novel_home_action_button.dart';
import 'package:novel_v3/app/action_buttons/search_button.dart';
import 'package:novel_v3/app/components/novel_see_all_view.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:novel_v3/app/general_server/general_server_noti_button.dart';
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

  Future<void> init({bool isReset = false}) async {
    context.read<NovelProvider>().initList(isReset: isReset);
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
            const GeneralServerNotiButton(),
            const SearchButton(),
            PlatformExtension.isDesktop()
                ? IconButton(
                    onPressed: () {
                      init(isReset: true);
                    },
                    icon: const Icon(Icons.refresh),
                  )
                : const SizedBox.shrink(),
            //menu
            const NovelHomeActionButton(),
          ],
        ),

        // Recent
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            showLines: 1,
            margin: const EdgeInsets.only(bottom: 20),
            title: 'မကြာခင်က',
            list: recentList,
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
            title: 'ပြီးဆုံး စာစဥ်များ',
            list: list.where((nv) => nv.isCompleted).toList(),
            onSeeAllClicked: _goShowAllScreen,
            onClicked: _goContentScreen,
          ),
        ),
        // OnGoing
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'ဆက်သွားနေဆဲ စာစဥ်များ',
            list: list.where((nv) => !nv.isCompleted).toList(),
            onSeeAllClicked: _goShowAllScreen,
            onClicked: _goContentScreen,
          ),
        ),
        // Adult
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'Adult စာစဥ်များ',
            list: list.where((nv) => nv.isAdult).toList(),
            onSeeAllClicked: _goShowAllScreen,
            onClicked: _goContentScreen,
          ),
        ),

        // Book Mark
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            showLines: 1,
            margin: const EdgeInsets.only(bottom: 20),
            title: 'Book Mark',
            list: bookList,
            onSeeAllClicked: _goShowAllScreen,
            onClicked: _goContentScreen,
          ),
        ),
        // Random
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            showLines: 1,
            margin: const EdgeInsets.only(bottom: 20),
            title: 'ကျပန်း စာစဥ်များ',
            list: randomList,
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
      body: isLoading
          ? TLoader()
          : RefreshIndicator(
              onRefresh: () async {
                init(isReset: true);
              },
              child: _getListWidget(list),
            ),
    );
  }
}
