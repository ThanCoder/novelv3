import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc_routes_func.dart';
import 'package:novel_v3/bloc_app/ui/components/refresh_btn_component.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/add_chapter_from_online_screen.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/add_chapter_list_from_online_screen.dart';
import 'package:novel_v3/bloc_app/ui/forms/add_chapter_form.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
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
    await context.read<ChapterListCubit>().fetchList(isCached: isCached);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChapterListCubit, ChapterListState>(
      builder: (context, state) {
        return RefreshIndicator.adaptive(
          onRefresh: () async => init(isCached: false),
          child: CustomScrollView(
            slivers: [
              _appbar(state),
              if (state.isLoading)
                SliverFillRemaining(child: Center(child: TLoader.random()))
              else if (state.errorMessage != null)
                SliverFillRemaining(
                  child: Center(child: Text('Error: ${state.errorMessage}')),
                )
              else if (state.list.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: RefreshBtnComponent(
                      text: Text('Chapter List Empty...'),
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

  Widget _appbar(ChapterListState state) {
    return SliverAppBar(
      snap: true,
      floating: true,
      // pinned: true,
      automaticallyImplyLeading: false,
      title: state.list.isEmpty
          ? null
          : Text('Count: ${state.list.length}', style: TextStyle(fontSize: 16)),
      actions: [
        if (TPlatform.isDesktop)
          IconButton(
            onPressed: () => init(isCached: false),
            icon: Icon(Icons.refresh),
          ),
        state.list.isEmpty
            ? SizedBox.shrink()
            : IconButton(
                onPressed: () => _showSortDialog(state.sortAsc),
                icon: Icon(Icons.sort),
              ),
        IconButton(onPressed: _showMainMenu, icon: Icon(Icons.more_vert)),
      ],
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
    return InkWell(
      onSecondaryTap: () => _showItemMenu(chapter),
      child: ListTile(
        textColor: Theme.brightnessOf(context).isDark
            ? Colors.white
            : Colors.black,
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
        onLongPress: () => _showItemMenu(chapter),
      ),
    );
  }

  void _showSortDialog(bool isAsc) {
    showTSortDialog(
      context,
      isAsc: isAsc,
      sortList: [
        TSort(
          id: 1,
          title: 'Chapter',
          ascTitle: 'Up Smallest',
          descTitle: 'Up Biggest',
        ),
      ],
      sortDialogCallback: (id, isAsc) {
        context.read<ChapterListCubit>().sort(isAsc);
      },
    );
  }

  // show menu
  void _showMainMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Chapter'),
          onTap: () {
            context.closeNavigator();
            goBlocRoute(
              context,
              builder: (context) => AddChapterForm(novel: widget.novel),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Chapter List From Online'),
          onTap: () {
            context.closeNavigator();
            _addChapterListFromOnline();
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Chapter From Online'),
          onTap: () {
            context.closeNavigator();
            _addChapterFromOnline();
          },
        ),
      ],
    );
  }

  void _addChapterFromOnline() {
    goBlocRoute(
      context,
      builder: (context) => AddChapterFromOnlineScreen(
        // url: 'https://mmxianxia.com/chapters/1362057/',
        existsChapterNumber: (chapterNumber) =>
            context.read<ChapterListCubit>().existsChapterNumber(chapterNumber),
        onSaved: (result) async {
          final (isAdded, isUpdated) = await context
              .read<ChapterListCubit>()
              .addOrUpdate(
                Chapter.create(
                  number: result.number,
                  novelId: widget.novel.id,
                  title: result.title,
                  content: result.content,
                ),
              );
          if (!mounted) return;
          showTSnackBar(
            context,
            isAdded ? '${result.number}: Added' : '${result.number}: Updated',
          );
        },
      ),
    );
  }

  void _addChapterListFromOnline() {
    goBlocRoute(
      context,
      builder: (context) => AddChapterListFromOnlineScreen(
        url: widget.novel.meta.pageUrls.first,
        existsChapterNumber: (chapterNumber) =>
            context.read<ChapterListCubit>().existsChapterNumber(chapterNumber),
        onSaved: (result) async {
          final (isAdded, isUpdated) = await context
              .read<ChapterListCubit>()
              .addOrUpdate(
                Chapter.create(
                  number: result.number,
                  novelId: widget.novel.id,
                  title: result.title,
                  content: result.content,
                ),
              );
          if (!mounted) return;
          showTSnackBar(
            context,
            isAdded ? '${result.number}: Added' : '${result.number}: Updated',
            showCloseIcon: true,
          );
        },
      ),
    );
  }

  void _showItemMenu(Chapter chapter) {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Edit Chapter'),
          onTap: () {
            context.closeNavigator();
            goBlocRoute(
              context,
              builder: (context) =>
                  AddChapterForm(novel: widget.novel, currentChapter: chapter),
            );
          },
        ),
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever),
          title: Text('Delete Chapter'),
          onTap: () {
            context.closeNavigator();
            _deleteChapter(chapter);
          },
        ),
      ],
    );
  }

  void _deleteChapter(Chapter chapter) {
    showTConfirmDialog(
      context,
      barrierDismissible: false,
      contentText: '`${chapter.number}` ကိုဖျက်ချင်တာသေချာပြီလား?',
      submitText: 'Delete Forever',
      onSubmit: () {
        try {
          context.read<ChapterListCubit>().delete(chapter);
        } catch (e) {
          showTMessageDialogError(context, e.toString());
        }
      },
    );
  }
}
