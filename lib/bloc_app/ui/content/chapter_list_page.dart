import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc_routes_func.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ChapterListPage extends StatefulWidget {
  final Novel novel;
  const ChapterListPage({super.key, required this.novel});

  @override
  State<ChapterListPage> createState() => _ChapterListPageState();
}

class _ChapterListPageState extends State<ChapterListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init({bool isCached = true}) async {
    await context.read<ChapterListCubit>().fetchList(
      widget.novel.id,
      isCached: isCached,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChapterListCubit, ChapterListState>(
      builder: (context, state) {
        return RefreshIndicator.adaptive(
          onRefresh: () async => init(isCached: false),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                snap: true,
                floating: true,
                pinned: false,
                automaticallyImplyLeading: false,
                // primary: false,
                actions: [
                  !TPlatform.isDesktop
                      ? SizedBox.shrink()
                      : IconButton(onPressed: init, icon: Icon(Icons.refresh)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                ],
              ),
              if (state.isLoading)
                SliverFillRemaining(child: Center(child: TLoader.random()))
              else if (state.errorMessage != null)
                SliverFillRemaining(
                  child: Center(child: Text('Error: ${state.errorMessage}')),
                )
              else
                _chapterList(state.list),
            ],
          ),
        );
      },
    );
  }

  Widget _chapterList(List<Chapter> list) {
    return SliverList.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: list.length,
      itemBuilder: (context, index) => _listItem(list[index]),
    );
  }

  Widget _listItem(Chapter chapter) {
    return ListTile(
      titleTextStyle: TextStyle(fontSize: 13),
      title: Row(
        children: [
          Text(
            '${chapter.number.toString()} : ',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Text(
              chapter.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
      onTap: () {
        goBlocChapterReader(context, chapter: chapter);
      },
    );
  }
}
