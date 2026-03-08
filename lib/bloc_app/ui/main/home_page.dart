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
      appBar: AppBar(title: Text('Novel Bloc')),
      body: BlocBuilder<NovelListCubit, NovelListState>(
        builder: (context, state) {
          return RefreshIndicator.adaptive(
            onRefresh: context.read<NovelListCubit>().fetchNovel,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: NovelTypeTabbar()),
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
      floatingActionButton: FloatingActionButton(
        onPressed: context.read<NovelListCubit>().fetchNovel,
      ),
    );
  }

  Widget _listStyle(List<Novel> list) {
    return SliverListStyle(list: list, onClicked: _onClicked);
  }

  void _onClicked(Novel novel) {
    context.push('/content/${novel.id}');
  }
}
