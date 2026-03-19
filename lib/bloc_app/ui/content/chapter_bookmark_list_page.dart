import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_bookmark_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc_routes_func.dart';
import 'package:novel_v3/bloc_app/ui/components/chapter_bookmark_toggler.dart';
import 'package:novel_v3/bloc_app/ui/components/refresh_btn_component.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/chapter_bookmark.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/extensions/t_platform.dart';

class ChapterBookmarkListPage extends StatefulWidget {
  final Novel novel;
  const ChapterBookmarkListPage({super.key, required this.novel});

  @override
  State<ChapterBookmarkListPage> createState() =>
      _ChapterBookmarkListPageState();
}

class _ChapterBookmarkListPageState extends State<ChapterBookmarkListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    await context.read<ChapterBookmarkListCubit>().fetch();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChapterBookmarkListCubit, ChapterBookmarkListCubitState>(
      builder: (context, state) {
        return RefreshIndicator.adaptive(
          onRefresh: init,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                snap: true,
                floating: true,
                // pinned: true,
                automaticallyImplyLeading: false,
                title: state.list.isEmpty
                    ? null
                    : Text(
                        'Count: ${state.list.length}',
                        style: TextStyle(fontSize: 16),
                      ),
                actions: [
                  !TPlatform.isDesktop
                      ? SizedBox.shrink()
                      : IconButton(onPressed: init, icon: Icon(Icons.refresh)),
                  // state.list.isEmpty
                  //     ? SizedBox.shrink()
                  //     : IconButton(
                  //         onPressed: () => _showSortDialog(state.sortAsc),
                  //         icon: Icon(Icons.sort),
                  //       ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                ],
              ),
              if (state.isLoading)
                SliverFillRemaining(child: Center(child: TLoader.random()))
              else if (state.errorMessage.isNotEmpty)
                SliverFillRemaining(
                  child: Center(child: Text('Error: ${state.errorMessage}')),
                )
              else if (state.list.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: RefreshBtnComponent(
                      text: Text('Pdf မရှိပါ...'),
                      onClicked: init,
                    ),
                  ),
                )
              else
                _chapterList(state.list),
            ],
          ),
        );
      },
    );
  }

  Widget _chapterList(List<ChapterBookmark> list) {
    return SliverList.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: list.length,
      itemBuilder: (context, index) => _listItem(list[index]),
    );
  }

  Widget _listItem(ChapterBookmark bookmark) {
    return InkWell(
      onTap: () => _goReader(bookmark),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 8,
          children: [
            Text(
              bookmark.chapter.toString(),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              bookmark.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Spacer(),
            ChapterBookmarkToggler(bookmark: bookmark),
          ],
        ),
      ),
    );
  }

  void _goReader(ChapterBookmark bookmark) {
    final chapter = Chapter.create(
      number: bookmark.chapter,
      novelId: widget.novel.id,
    );
    goBlocChapterReader(context, chapter: chapter);
  }

  // void _showSortDialog(bool isAsc) {
  //   showTSortDialog(
  //     context,
  //     currentId: context.read<ChapterBookmarkListCubit>().state.sortId,
  //     isAsc: context.read<ChapterBookmarkListCubit>().state.sortAsc,
  //     sortList: ChapterBookmarkListCubit.sortList,
  //     sortDialogCallback: (id, isAsc) {
  //       context.read<ChapterBookmarkListCubit>().sort(id, isAsc);
  //     },
  //   );
  // }
}
