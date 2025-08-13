import 'package:flutter/material.dart';
import 'package:novel_v3/app/screens/forms/edit_novel_form.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/routes_helper.dart';
import 'package:novel_v3/more_libs/sort_dialog_v1.0.0/sort_func.dart';
import 'package:t_widgets/t_widgets.dart';
import '../novel_search_screen.dart';
import 'package:provider/provider.dart';
import '../../novel_dir_app.dart';

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
    await context.read<NovelProvider>().initList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novel V3 Pre'),
        actions: [
          _getSearchButton(),
          IconButton(onPressed: _showMenu, icon: Icon(Icons.more_vert_rounded)),
        ],
      ),
      body: _getList(),
    );
  }

  Widget _getSearchButton() {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NovelSearchScreen()),
        );
      },
      icon: Icon(Icons.search),
    );
  }

  Widget _getList() {
    final provider = context.watch<NovelProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;
    final completedList = list.where((e) => e.isCompleted).toList();
    final onGoingList = list.where((e) => !e.isCompleted).toList();
    final adultList = list.where((e) => e.isAdult).toList();
    final randomList = List.of(list);
    randomList.shuffle();

    if (isLoading) {
      return Center(child: TLoaderRandom());
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: NovelSeeAllView(title: 'ကျပန်း စာစဥ်များ', list: randomList),
        ),
        SliverToBoxAdapter(
          child: NovelSeeAllView(title: 'Latest စာစဥ်များ', list: list),
        ),
        SliverToBoxAdapter(
          child: NovelSeeAllView(
            title: 'Completed စာစဥ်များ',
            list: completedList,
          ),
        ),
        SliverToBoxAdapter(
          child: NovelSeeAllView(title: 'OnGoing စာစဥ်များ', list: onGoingList),
        ),
        SliverToBoxAdapter(
          child: NovelSeeAllView(title: 'Adult စာစဥ်များ', list: adultList),
        ),
      ],
    );
  }

  // main menu
  void _showMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add'),
          onTap: () {
            closeContext(context);
            _showAddMainMenu();
          },
        ),
        ListTile(
          leading: Icon(Icons.sort),
          title: Text('Sort'),
          onTap: () {
            closeContext(context);
            _showSort();
          },
        ),
      ],
    );
  }

  void _showSort() {
    final provider = context.read<NovelProvider>();
    showSortDialog(
      context,
      value: provider.sortType,
      onChanged: (type) {
        provider.sortList(type);
      },
    );
  }

  // add main menu
  void _showAddMainMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Novel'),
          onTap: () {
            closeContext(context);
            _addNewNovel();
          },
        ),
      ],
    );
  }

  void _addNewNovel() {
    final provider = context.read<NovelProvider>();
    final list = provider.getList;

    showTReanmeDialog(
      context,
      barrierDismissible: false,
      autofocus: true,
      submitText: 'New',
      title: Text('New Title'),
      onCheckIsError: (text) {
        final index = list.indexWhere((e) => e.title == text);
        if (index != -1) {
          return 'title ရှိနေပြီးသားဖြစ်နေပါတယ်!...';
        }
        return null;
      },
      text: 'Untitled',
      onSubmit: (text) {
        if (text.isEmpty) return;
        final novel = Novel.createTitle(text.trim());
        provider.add(novel);
        goRoute(context, builder: (context) => EditNovelForm(novel: novel));
      },
    );
  }
}
