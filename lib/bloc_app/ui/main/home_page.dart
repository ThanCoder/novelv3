import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_bookmark_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_type_tabbar_cubit.dart';
import 'package:novel_v3/bloc_app/bloc_routes_func.dart';
import 'package:novel_v3/bloc_app/ui/main/novel_type_tabbar.dart';
import 'package:novel_v3/bloc_app/ui/main/styles/sliver_list_style.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/utils.dart';
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
    return SliverListStyle(list: list, onClicked: _onClicked);
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
          title: Text('Add From Internet'),
          onTap: () {
            context.closeNavigator();
            goAddNovelFromInternetScreen(context);
          },
        ),
      ],
    );
  }

  void _onClicked(Novel novel) {
    // context.push('/content/${novel.id}');
    goNovelContentScreen(context, novel: novel);
  }
}
