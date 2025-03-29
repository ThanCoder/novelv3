import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_list_view.dart';
import 'package:novel_v3/app/components/novel_see_all_list_view.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/customs/novel_search_delegate.dart';
import 'package:novel_v3/app/dialogs/add_new_novel_dialog.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:novel_v3/app/screens/novel_screens/novel_content_screen.dart';
import 'package:novel_v3/app/screens/novel_screens/novel_data_scanner_screen.dart';
import 'package:novel_v3/app/screens/novel_screens/novel_show_all_screen.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:novel_v3/app/services/novel_recent_services.dart';
import 'package:provider/provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  //init
  Future<void> init({bool isReset = false}) async {
    context.read<NovelProvider>().initList(isReset: isReset);
    novelBookMarkListNotifier.value = [];
    novelBookMarkListNotifier.value =
        await NovelBookmarkServices.instance.getList();
  }

  //menu
  void showBottomMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 150),
          child: Column(
            children: [
              //add new novel
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        AddNewNovelDialog(dialogContext: context),
                  );
                },
                leading: const Icon(Icons.add),
                title: const Text('Add New Novel'),
              ),
              //add new novel from data
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NovelDataScannerScreen(),
                    ),
                  );
                },
                leading: const Icon(Icons.add),
                title: const Text('Add Novel Data File'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchBar() {
    showSearch(
      context: context,
      delegate:
          NovelSearchDelegate(novelList: context.read<NovelProvider>().getList),
    );
  }

  void _goContentPage(NovelModel novel) {
    currentNovelNotifier.value = novel;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelContentScreen(novel: novel),
      ),
    );
  }

  Widget _getList(List<NovelModel> novelList) {
    //is empty
    if (novelList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Novel List မရှိပါ...'),
            TextButton(
              onPressed: () {
                init();
              },
              child: const Icon(
                Icons.refresh,
                size: 30,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 700));
        init();
      },
      child: NovelListView(
        novelList: novelList,
        onClick: _goContentPage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NovelProvider>();
    final isLoading = provider.isLoading;
    final novelList = provider.getList;
    final adultList = novelList.where((nv) => nv.isAdult).toList();
    final completedList = novelList.where((nv) => nv.isCompleted).toList();
    final onGoingList = novelList.where((nv) => !nv.isCompleted).toList();
    //random
    final randomList = List.of(novelList);
    randomList.shuffle();

    if (isLoading) {
      return TLoader();
    }
    return RefreshIndicator(
      onRefresh: () async {
        init(isReset: true);
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(appTitle),
            floating: true,
            snap: true,
            pinned: false,
            actions: [
              //search
              IconButton(
                onPressed: () {
                  _showSearchBar();
                },
                icon: const Icon(Icons.search),
              ),
              //refresh
              Platform.isLinux
                  ? IconButton(
                      onPressed: () {
                        init(isReset: true);
                      },
                      icon: const Icon(Icons.refresh),
                    )
                  : const SizedBox.shrink(),
              //more
              IconButton(
                onPressed: () {
                  showBottomMenu();
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),

          //recent Novel
          SliverToBoxAdapter(
            child: FutureBuilder(
              future: NovelRecentServices.instance.getList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return TLoader();
                }
                if (snapshot.hasData) {
                  return NovelSeeAllListView(
                    title: 'မကြာခင်က',
                    list: snapshot.data ?? [],
                    onClicked: _goContentPage,
                    onSeeAllClicked: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NovelShowAllScreen(
                            title: 'မကြာခင်က',
                            list: snapshot.data ?? [],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          //bookmark Novel
          SliverToBoxAdapter(
            child: ValueListenableBuilder(
              valueListenable: novelBookMarkListNotifier,
              builder: (context, value, child) {
                return NovelSeeAllListView(
                  title: 'မှတ်သားထားသော',
                  list: value,
                  onClicked: _goContentPage,
                  onSeeAllClicked: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NovelShowAllScreen(
                          title: 'မှတ်သားထားသော',
                          list: value,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          //Latest Novel
          SliverToBoxAdapter(
            child: NovelSeeAllListView(
              title: 'အသစ်များ',
              list: novelList,
              onClicked: _goContentPage,
              onSeeAllClicked: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NovelShowAllScreen(
                      title: 'အသစ်များ',
                      list: novelList,
                    ),
                  ),
                );
              },
            ),
          ),
          //Completed list
          SliverToBoxAdapter(
            child: NovelSeeAllListView(
              title: 'ပြီးဆုံးသွားတော့',
              list: completedList,
              onClicked: _goContentPage,
              onSeeAllClicked: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NovelShowAllScreen(
                      title: 'ပြီးဆုံးသွားတော့',
                      list: completedList,
                    ),
                  ),
                );
              },
            ),
          ),
          //OnGoing list
          SliverToBoxAdapter(
            child: NovelSeeAllListView(
              title: 'ဆက်ရေးနေဆဲ',
              list: onGoingList,
              onClicked: _goContentPage,
              onSeeAllClicked: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NovelShowAllScreen(
                      title: 'ဆက်ရေးနေဆဲ',
                      list: onGoingList,
                    ),
                  ),
                );
              },
            ),
          ),
          //Adult list
          SliverToBoxAdapter(
            child: NovelSeeAllListView(
              title: 'Adult Novel',
              list: adultList,
              onClicked: _goContentPage,
              onSeeAllClicked: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NovelShowAllScreen(
                      title: 'Adult Novel',
                      list: adultList,
                    ),
                  ),
                );
              },
            ),
          ),
          //random list
          SliverToBoxAdapter(
            child: NovelSeeAllListView(
              title: 'ကျပန်း ပြသခြင်း',
              list: randomList,
              onClicked: _goContentPage,
              onSeeAllClicked: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NovelShowAllScreen(
                      title: 'ကျပန်း ပြသခြင်း',
                      list: randomList,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
