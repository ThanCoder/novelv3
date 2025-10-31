import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_db.dart';
import 'package:novel_v3/app/others/recents/novel_recent_db.dart';
import 'package:novel_v3/app/providers/novel_provider.dart';
import 'package:novel_v3/app/ui/components/novel_grid_item.dart';
import 'package:novel_v3/app/ui/main_ui/screens/forms/edit_novel_form.dart';
import 'package:novel_v3/app/ui/routes_helper.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets_dev.dart';
import 'package:than_pkg/t_database/t_recent_db.dart';

class HomeGridStyle extends StatefulWidget {
  const HomeGridStyle({super.key});

  @override
  State<HomeGridStyle> createState() => _HomeGridStyleState();
}

class _HomeGridStyleState extends State<HomeGridStyle> {
  final List<String> filter = [
    'Latest',
    'Completed',
    'OnGoing',
    'Adult',
    'Not Adult',
    'Recent',
    'Book Mark',
  ];
  String? filterName;
  double itemHeight = 160;
  double itemWidth = 130;
  double itemSpacing = 3;

  @override
  void initState() {
    filterName = filter.first;
    super.initState();
    init();
  }

  void init() async {
    final name = TRecentDB.getInstance.getString(
      'home-grid-style-filter-name',
      def: filter.first,
    );
    setState(() {
      filterName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<NovelProvider>().getList;
    if (list.isEmpty) {
      return _getEmptyList();
    }
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        context.read<NovelProvider>().initList(isCached: false);
      },
      child: CustomScrollView(slivers: [_getHeader(), _getList(list)]),
    );
  }

  Widget _getEmptyList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Novel မရှိပါ!...'),
          IconButton(
            color: Colors.blue,
            onPressed: () {
              context.read<NovelProvider>().initList(isCached: false);
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _getHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          runSpacing: 3,
          spacing: 3,
          children: List.generate(filter.length, (index) {
            final name = filter[index];
            return TChip(
              avatar: name == filterName ? Icon(Icons.check) : null,
              title: Text(name),
              onClick: () {
                setState(() {
                  filterName = name;
                });
                TRecentDB.getInstance.putString(
                  'home-grid-style-filter-name',
                  name,
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _getList(List<Novel> list) {
    List<Novel> res = list;
    // bookmark recent
    if (filterName != null && filterName == 'Book Mark') {
      return _getBookMarkList();
    }
    if (filterName != null && filterName == 'Recent') {
      return _getRecentList();
    }
    if (filterName != null && filterName != 'Latest') {
      res = list.where((e) {
        if (filterName == 'Completed' && e.isCompleted) {
          return true;
        }
        if (filterName == 'OnGoing' && !e.isCompleted) {
          return true;
        }
        if (filterName == 'Adult' && e.isAdult) {
          return true;
        }
        if (filterName == 'Not Adult' && !e.isAdult) {
          return true;
        }
        return false;
      }).toList();
    }
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: itemWidth,
        mainAxisExtent: itemHeight,
        mainAxisSpacing: itemSpacing,
        crossAxisSpacing: itemSpacing,
      ),
      itemCount: res.length,
      itemBuilder: (context, index) => NovelGridItem(
        novel: res[index],
        onClicked: _onClicked,
        onRightClicked: _showItemMenu,
      ),
    );
  }

  Widget _getBookMarkList() {
    return FutureBuilder(
      future: NovelBookmarkDB.getInstance().getNovelList(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return SliverFillRemaining(child: Center(child: TLoaderRandom()));
        }
        if (asyncSnapshot.hasData) {
          final list = asyncSnapshot.data ?? [];
          return SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: itemWidth,
              mainAxisExtent: itemHeight,
              mainAxisSpacing: itemSpacing,
              crossAxisSpacing: itemSpacing,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) => NovelGridItem(
              novel: list[index],
              onClicked: _onClicked,
              onRightClicked: _showItemMenu,
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _getRecentList() {
    return FutureBuilder(
      future: NovelRecentDB.getInstance().getNovelList(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return SliverFillRemaining(child: Center(child: TLoaderRandom()));
        }
        if (asyncSnapshot.hasData) {
          final list = asyncSnapshot.data ?? [];
          return SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: itemWidth,
              mainAxisExtent: itemHeight,
              mainAxisSpacing: itemSpacing,
              crossAxisSpacing: itemSpacing,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) => NovelGridItem(
              novel: list[index],
              onClicked: _onClicked,
              onRightClicked: _showItemMenu,
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  void _onClicked(Novel novel) {
    goNovelContentScreen(context, novel);
  }

  void _showItemMenu(Novel novel) {
    showTMenuBottomSheet(
      context,
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(novel.title)),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit_document),
          title: Text('Edit'),
          onTap: () {
            closeContext(context);
            _goEditScreen(novel);
          },
        ),
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever_rounded),
          title: Text('Delete'),
          onTap: () {
            closeContext(context);
            _deleteConfirm(novel);
          },
        ),
      ],
    );
  }

  void _goEditScreen(Novel novel) {
    goRoute(context, builder: (context) => EditNovelForm(novel: novel));
  }

  void _deleteConfirm(Novel novel) {
    showTConfirmDialog(
      context,
      submitText: 'Delete Forever',
      contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
      onSubmit: () {
        context.read<NovelProvider>().delete(novel);
      },
    );
  }
}
