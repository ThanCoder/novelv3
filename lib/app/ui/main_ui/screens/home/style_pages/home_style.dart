import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/index.dart';

import 'package:novel_v3/app/providers/novel_provider.dart';
import 'package:novel_v3/app/ui/main_ui/screens/home/novel_bookmark_see_all_view.dart';
import 'package:novel_v3/app/ui/main_ui/screens/home/novel_recent_see_all_view.dart';
import 'package:novel_v3/app/ui/main_ui/screens/home/style_pages/novel_see_all_view.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:novel_v3/app/ui/routes_helper.dart';
import 'package:novel_v3/app/ui/main_ui/screens/forms/edit_novel_form.dart';

class HomeStyle extends StatefulWidget {
  const HomeStyle({super.key});

  @override
  State<HomeStyle> createState() => _HomeStyleState();
}

class _HomeStyleState extends State<HomeStyle> {
  @override
  Widget build(BuildContext context) {
    final list = context.watch<NovelProvider>().getList;
    final completedList = list.where((e) => e.meta.isCompleted).toList();
    final onGoingList = list.where((e) => !e.meta.isCompleted).toList();
    final adultList = list.where((e) => e.meta.isAdult).toList();
    final randomList = List.of(list);
    randomList.shuffle();
    if (list.isEmpty) {
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RefreshIndicator.noSpinner(
        onRefresh: () async {
          context.read<NovelProvider>().initList(isCached: false);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: NovelRecentSeeAllView(
                onClicked: _onClicked,
                onRightClicked: _showItemMenu,
              ),
            ),
            SliverToBoxAdapter(
              child: NovelSeeAllView(
                title: 'Latest စာစဥ်များ',
                list: list,
                onClicked: _onClicked,
                onRightClicked: _showItemMenu,
              ),
            ),
            SliverToBoxAdapter(
              child: NovelBookmarkSeeAllView(
                onClicked: _onClicked,
                onRightClicked: _showItemMenu,
              ),
            ),
            SliverToBoxAdapter(
              child: NovelRecentSeeAllView(
                onClicked: _onClicked,
                onRightClicked: _showItemMenu,
              ),
            ),
            SliverToBoxAdapter(
              child: NovelSeeAllView(
                title: 'ကျပန်း စာစဥ်များ',
                list: randomList,
                onClicked: _onClicked,
                onRightClicked: _showItemMenu,
              ),
            ),

            SliverToBoxAdapter(
              child: NovelSeeAllView(
                title: 'Completed စာစဥ်များ',
                list: completedList,
                onClicked: _onClicked,
                onRightClicked: _showItemMenu,
              ),
            ),
            SliverToBoxAdapter(
              child: NovelSeeAllView(
                title: 'OnGoing စာစဥ်များ',
                list: onGoingList,
                onClicked: _onClicked,
                onRightClicked: _showItemMenu,
              ),
            ),
            SliverToBoxAdapter(
              child: NovelSeeAllView(
                title: 'Adult စာစဥ်များ',
                list: adultList,
                onClicked: _onClicked,
                onRightClicked: _showItemMenu,
              ),
            ),
          ],
        ),
      ),
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
