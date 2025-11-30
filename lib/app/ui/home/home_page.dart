import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/components/novel_list_item.dart';
import 'package:novel_v3/app/ui/content/content_screen.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:provider/provider.dart';

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

  Future<void> init({bool isUsedCache = true}) async {
    await context.read<NovelProvider>().init(isUsedCache: isUsedCache);
  }

  NovelProvider get getProvider => context.watch<NovelProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () async => init(isUsedCache: false),
        child: CustomScrollView(slivers: [_getAppbar(), _getListWidget()]),
      ),
    );
  }

  Widget _getAppbar() {
    return SliverAppBar(
      title: Text(Setting.instance.appName),
      snap: true,
      floating: true,
      pinned: false,
    );
  }

  Widget _getListWidget() {
    if (getProvider.list.isEmpty) {
      return SliverFillRemaining(child: Center(child: Text('Empty List!')));
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
    );
  }
}
