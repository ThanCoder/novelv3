import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_bookmark_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_type_tabbar_cubit.dart';
import 'package:novel_v3/bloc_app/bloc_routes_func.dart';
import 'package:novel_v3/bloc_app/ui/components/refresh_btn_component.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/add_novel_detail_from_online_screen.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetch_novel_from_url_menu.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/result_types.dart';

import 'package:novel_v3/bloc_app/ui/main/novel_type_tabbar.dart';
import 'package:novel_v3/bloc_app/ui/main/styles/sliver_list_style.dart';
import 'package:novel_v3/bloc_app/ui/webview/fetch_webview_screen.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:novel_v3/other_apps/novel_clean_up/novel_clean_up_screen.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<NovelBookmarkListCubit, NovelBookmarkListCubitState>(
      listener: (context, state) {
        final type = context.read<NovelTypeTabbarCubit>().state;
        // bookmark ဖြစ်နေရင် list ကို update လုပ်မယ်
        if (type != NovelTypes.bookmark) return;

        context.read<NovelListCubit>().setList(state.list);
      },
      child: Scaffold(
        body: BlocConsumer<NovelListCubit, NovelListState>(
          listener: (context, state) {
            if (state.isInit) {
              context.read<NovelTypeTabbarCubit>().setCurrent(
                NovelTypes.latest,
              );
            }
          },
          builder: (context, state) {
            return RefreshIndicator.adaptive(
              onRefresh: context.read<NovelListCubit>().fetchNovel,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(title: Text('Novel Bloc'), actions: _actions()),
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    pinned: false,
                    // toolbarHeight: 50,
                    flexibleSpace: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NovelTypeTabbar(),
                      ),
                    ),
                  ),

                  if (state.isLoading)
                    SliverFillRemaining(child: TLoader.random()),
                  if (state.errorMessage.isNotEmpty)
                    SliverFillRemaining(
                      child: Text('Error: ${state.errorMessage}'),
                    ),
                  if (state.list.isEmpty)
                    SliverFillRemaining(
                      child: RefreshBtnComponent(
                        text: Text('List Empty'),
                        onClicked: context.read<NovelListCubit>().fetchNovel,
                      ),
                    ),
                  _listStyle(state.list),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _actions() {
    return [
      if (TPlatform.isDesktop)
        IconButton(
          onPressed: () => context.read<NovelListCubit>().fetchNovel(),
          icon: Icon(Icons.refresh),
        )
      else
        SizedBox.shrink(),
      IconButton(
        onPressed: () => goBlocSearch(context),
        icon: Icon(Icons.search),
      ),
      IconButton(onPressed: _showSort, icon: Icon(Icons.sort)),
      IconButton(onPressed: _showMenu, icon: Icon(Icons.more_vert)),
    ];
  }

  Widget _listStyle(List<Novel> list) {
    return SliverListStyle(
      list: list,
      onClicked: _onClicked,
      onRightClicked: _onItemMenu,
    );
  }

  void _showSort() {
    showTSortDialog(
      context,
      sortList: NovelListCubit.sortList,
      currentId: context.read<NovelListCubit>().state.sortId,
      isAsc: context.read<NovelListCubit>().state.sortAsc,
      sortDialogCallback: (id, isAsc) {
        context.read<NovelListCubit>().sort(id, isAsc);
      },
    );
  }

  void _showMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('New Novel'),
          onTap: () async {
            context.closeNavigator();
            _showAddNovelMenu();
          },
        ),
        ListTile(
          leading: Icon(Icons.cleaning_services),
          title: Text('Novel Clean Up'),
          onTap: () async {
            context.closeNavigator();
            context.goRoute(builder: (context) => NovelCleanUpScreen());
          },
        ),
        ListTile(
          leading: Icon(Icons.open_in_browser),
          title: Text('Webview'),
          onTap: () async {
            context.closeNavigator();
            context.goRoute(builder: (context) => FetchWebviewScreen());
          },
        ),
      ],
    );
  }

  // add novel menu
  void _showAddNovelMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('New Novel From'),
          onTap: () async {
            context.closeNavigator();
            final newNovel = await context
                .read<NovelListCubit>()
                .createNewNovel();
            if (!mounted) return;
            goNovelEditScreen(context, novel: newNovel);
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add From Internet Websites'),
          onTap: () {
            context.closeNavigator();
            goAddNovelFromInternetScreen(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add From Internet Website Url'),
          onTap: () {
            context.closeNavigator();
            _showAddFromWebsiteUrl();
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add From PDF Files'),
          onTap: () {
            context.closeNavigator();
            goAddFromPdfScreen(context);
          },
        ),
      ],
    );
  }

  void _showAddFromWebsiteUrl() {
    showTMenuBottomSheetSingle(
      context,
      title: Text('Fetch Website Info From Url'),
      child: FetchNovelFromUrlMenu(
        onApply: (url, site) {
          goBlocRoute(
            context,
            builder: (context) => AddNovelDetailFromOnlineScreen(
              item: NovelItemResult(title: '', pageUrl: url, coverUrl: ''),
              site: site,
              isExists: (title) =>
                  context.read<NovelListCubit>().isExists(title),
              onClosed: (createdNovel) {
                if (createdNovel == null) return;
                context.read<NovelListCubit>().addNew(createdNovel);
              },
            ),
          );
        },
      ),
    );
  }

  // item menu
  void _onItemMenu(Novel novel) {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.edit_document),
          title: Text('Edit Novel'),
          onTap: () {
            context.closeNavigator();
            goNovelEditScreen(context, novel: novel);
          },
        ),
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever),
          title: Text('Delete'),
          onTap: () {
            context.closeNavigator();
            _deleteConfirm(novel);
          },
        ),
      ],
    );
  }

  void _deleteConfirm(Novel novel) {
    showTConfirmDialog(
      context,
      contentText: 'ဖျက်ချင်တာ သေချာပြီးလား?',
      submitText: 'Delete Forever',
      onSubmit: () {
        context.read<NovelListCubit>().delete(novel);
      },
    );
  }

  void _onClicked(Novel novel) {
    // context.push('/content/${novel.id}');
    goNovelContentScreen(context, novel: novel);
  }
}
