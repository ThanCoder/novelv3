import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/action_buttons/novel_home_action_button.dart';
import 'package:novel_v3/app/action_buttons/search_button.dart';
import 'package:novel_v3/app/components/novel_see_all_view.dart';
import 'package:novel_v3/app/my_libs/general_server/general_server_noti_button.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/screens/novel_see_all_screen.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../../constants.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init({bool isReset = false}) async {
    await ref.read(novelNotifierProvider.notifier).initList(isReset: isReset);
    await ref.read(bookmarkNotifierProvider.notifier).initList();
    await ref.read(recentNotifierProvider.notifier).initList();
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
    goNovelContentPage(context, ref, novel);
  }

  Widget _getListWidget(List<NovelModel> list) {
    final randomList = List.of(list);
    randomList.shuffle();

    List<NovelModel> bookList = ref.watch(bookmarkNotifierProvider).list;
    List<NovelModel> recentList = ref.watch(recentNotifierProvider).list;
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
    final provider = ref.watch(novelNotifierProvider);
    final isLoading = provider.isLoading;
    List<NovelModel> list = provider.list;

    return Scaffold(
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
