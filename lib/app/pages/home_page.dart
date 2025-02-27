import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_list_view.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/customs/novel_search_delegate.dart';
import 'package:novel_v3/app/dialogs/add_new_novel_dialog.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:novel_v3/app/screens/novel_screens/novel_content_screen.dart';
import 'package:novel_v3/app/screens/novel_screens/novel_data_scanner_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/index.dart';

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
  void init() async {
    context.read<NovelProvider>().initList();
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

    return CustomScrollView(
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
            //more
            IconButton(
              onPressed: () {
                showBottomMenu();
              },
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        if (isLoading)
          SliverToBoxAdapter(
            child: TLoader(),
          )
        else
          SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisExtent: 220,
              crossAxisSpacing: 0.5,
              mainAxisSpacing: 0.5,
            ),
            itemBuilder: (context, index) => NovelListViewItem(
              novel: novelList[index],
              onClick: _goContentPage,
            ),
            itemCount: novelList.length,
          ),
      ],
    );

    /*return MyScaffold(
        appBar: AppBar(
          title: const Text(appTitle),
          actions: [
            //search
            IconButton(
              onPressed: () {
                _showSearchBar();
              },
              icon: const Icon(Icons.search),
            ),
            //more
            IconButton(
              onPressed: () {
                showBottomMenu();
              },
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: isLoading
            ? Center(
                child: TLoader(),
              )
            : _getList(novelList),);*/
  }
}
