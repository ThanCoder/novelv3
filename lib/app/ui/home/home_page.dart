import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/components/novel_list_item.dart';
import 'package:novel_v3/app/ui/content/content_screen.dart';
import 'package:novel_v3/app/ui/home/home_menu_actions.dart';
import 'package:novel_v3/app/ui/home/novel_item_menu_actions.dart';
import 'package:novel_v3/app/ui/home/novel_sliver_tags_bar.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:provider/provider.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

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

  String? currentTag;

  Future<void> init({bool isUsedCache = true}) async {
    await context.read<NovelProvider>().init(isUsedCache: isUsedCache);
  }

  NovelProvider get getProvider => context.watch<NovelProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Setting.instance.appName),
        actions: [
          !TPlatform.isDesktop
              ? SizedBox.shrink()
              : IconButton(
                  onPressed: () => init(isUsedCache: false),
                  icon: Icon(Icons.refresh),
                ),
          HomeMenuActions(),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async => init(isUsedCache: false),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // _getAppbar(),
            NovelSliverTagsBar(value: currentTag, onChoosed: _onChoosedTag),
          ],
          body: CustomScrollView(slivers: [_getListWidget()]),
        ),
      ),
    );
  }

  // Widget _getAppbar() {
  //   return SliverAppBar(
  //     title: Text(Setting.instance.appName),
  //     actions: [
  //       !TPlatform.isDesktop
  //           ? SizedBox.shrink()
  //           : IconButton(
  //               onPressed: () => init(isUsedCache: false),
  //               icon: Icon(Icons.refresh),
  //             ),
  //       HomeMenuActions(),
  //     ],
  //   );
  // }

  List<Novel> filterdNovelList = [];

  Widget _getListWidget() {
    if (getProvider.list.isEmpty) {
      return SliverFillRemaining(child: Center(child: Text('Empty List!')));
    }
    if (currentTag != null && currentTag != novelSliverTags.first) {
      if (filterdNovelList.isEmpty) {
        return SliverFillRemaining(child: Center(child: Text('Empty List!')));
      }
      return SliverList.builder(
        itemCount: filterdNovelList.length,
        itemBuilder: (context, index) => _getListItem(filterdNovelList[index]),
      );
    }
    return SliverList.builder(
      itemCount: getProvider.list.length,
      itemBuilder: (context, index) => _getListItem(getProvider.list[index]),
    );
  }

  Widget _getListItem(Novel novel) {
    return NovelListItem(
      novel: novel,
      onClicked: (novel) async {
        await context.read<NovelProvider>().setCurrentNovel(novel);
        if (!mounted) return;
        goRoute(context, builder: (context) => ContentScreen());
      },
      onRightClicked: _onItemMenu,
    );
  }

  // filter tags
  void _onChoosedTag(String tag) {
    final list = context.read<NovelProvider>().list;
    filterdNovelList = list.where((e) {
      if (tag == 'BookMark') {}
      if (tag == 'Completed' && e.meta.isCompleted) {
        return true;
      }
      if (tag == 'OnGoing' && !e.meta.isCompleted) {
        return true;
      }
      if (tag == 'No Adult' && !e.meta.isAdult) {
        return true;
      }
      if (tag == 'Adult' && e.meta.isAdult) {
        return true;
      }
      return false;
    }).toList();
    setState(() {
      currentTag = tag;
    });
  }

  // item menu
  void _onItemMenu(Novel novel) {
    showTMenuBottomSheetSingle(
      context,
      title: Text(novel.title),
      child: NovelItemMenuActions(novel: novel),
    );
  }
}
