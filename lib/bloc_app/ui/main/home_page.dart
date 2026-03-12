import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:novel_v3/bloc_app/bloc/novel_list_cubit.dart';
import 'package:novel_v3/bloc_app/ui/main/novel_type_tabbar.dart';
import 'package:novel_v3/bloc_app/ui/main/styles/sliver_list_style.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NovelListCubit, NovelListState>(
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
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: NovelTypeTabbar(),
                  ),
                ),

                if (state.isLoading)
                  SliverFillRemaining(child: TLoader.random()),
                if (state.errorMessage != null)
                  SliverFillRemaining(
                    child: Text('Error: ${state.errorMessage}'),
                  ),
                _listStyle(state.list),
              ],
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: context.read<NovelListCubit>().fetchNovel,
      // ),
    );
  }

  List<Widget> _actions() {
    return [IconButton(onPressed: _showSort, icon: Icon(Icons.sort))];
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

  void _onClicked(Novel novel) {
    context.push('/content/${novel.id}');
  }
}
