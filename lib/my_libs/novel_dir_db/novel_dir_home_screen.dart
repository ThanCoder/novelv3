import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/widgets/index.dart';
import 'novel_dir_db.dart';

class NovelDirHomeScreen extends StatefulWidget {
  const NovelDirHomeScreen({super.key});

  @override
  State<NovelDirHomeScreen> createState() => _NovelDirHomeScreenState();
}

class _NovelDirHomeScreenState extends State<NovelDirHomeScreen> {
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
        title: Text('Novel'),
      ),
      body: _getList(),
    );
  }

  Widget _getList() {
    final provider = context.watch<NovelProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;
    if(isLoading){
      return Center(child: TLoaderRandom());
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
            child: NovelSeeAllView(
          title: 'Latest',
          list: list,
          onClicked: (novel) {},
          onSeeAllClicked: (title, list) {},
        ))
      ],
    );
  }
}
