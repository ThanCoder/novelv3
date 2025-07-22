import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/components/novel_see_all_view.dart';
import 'package:novel_v3/app/setting/app_notifier.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/my_libs/novel_data/data_import_dialog.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:t_widgets/t_widgets.dart';

class NovelHomeListPage extends ConsumerStatefulWidget {
  AppBar? appBar;
  NovelHomeListPage({
    super.key,
    this.appBar,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NovelHomeListPageState();
}

class _NovelHomeListPageState extends ConsumerState<NovelHomeListPage> {
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
        // Recent
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            showLines: 1,
            margin: const EdgeInsets.only(bottom: 20),
            title: 'မကြာခင်က',
            list: recentList,
            onSeeAllClicked: (title, list) =>
                goSeeAllScreen(context, title, list),
            onClicked: _goContentScreen,
          ),
        ),

        // latest
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'နောက်ဆုံး',
            list: list,
            onSeeAllClicked: (title, list) =>
                goSeeAllScreen(context, title, list),
            onClicked: _goContentScreen,
          ),
        ),
        // Completed
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'ပြီးဆုံး စာစဥ်များ',
            list: list.where((nv) => nv.isCompleted).toList(),
            onSeeAllClicked: (title, list) =>
                goSeeAllScreen(context, title, list),
            onClicked: _goContentScreen,
          ),
        ),
        // OnGoing
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'ဆက်သွားနေဆဲ စာစဥ်များ',
            list: list.where((nv) => !nv.isCompleted).toList(),
            onSeeAllClicked: (title, list) =>
                goSeeAllScreen(context, title, list),
            onClicked: _goContentScreen,
          ),
        ),
        // Adult
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            margin: const EdgeInsets.only(bottom: 20),
            title: 'Adult စာစဥ်များ',
            list: list.where((nv) => nv.isAdult).toList(),
            onSeeAllClicked: (title, list) =>
                goSeeAllScreen(context, title, list),
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
            onSeeAllClicked: (title, list) =>
                goSeeAllScreen(context, title, list),
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
            onSeeAllClicked: (title, list) =>
                goSeeAllScreen(context, title, list),
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

    return ValueListenableBuilder(
        valueListenable: isFileDropHomePageNotifier,
        builder: (context, isCanDrop, child) {
          return DropTarget(
            enable: isCanDrop,
            onDragDone: (details) {
              if (details.files.isEmpty) return;
              final path = details.files.first.path;
              if (!NovelDataServices.isNovelData(path)) {
                showDialogMessage(context, 'Novel Data is required!');
                return;
              }
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => DataImportDialog(
                  path: path,
                  onDone: () {
                    init(isReset: true);
                  },
                ),
              );
            },
            child: Scaffold(
              appBar: widget.appBar,
              body: isLoading
                  ? TLoader()
                  : RefreshIndicator(
                      onRefresh: () async {
                        init(isReset: true);
                      },
                      child: _getListWidget(list),
                    ),
            ),
          );
        });
  }
}
