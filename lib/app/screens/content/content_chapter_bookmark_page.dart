import 'package:flutter/material.dart';
import 'package:novel_v3/app/bookmark/chapter_bookmark_data.dart';
import 'package:novel_v3/app/bookmark/chapter_bookmark_db.dart';
import 'package:novel_v3/app/bookmark/chapter_bookmark_list_item.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:novel_v3/app/screens/chapter_reader/chapter_reader_screen.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/extensions/index.dart';

import '../../novel_dir_app.dart';
import 'content_image_wrapper.dart';

class ContentChapterBookmarkPage extends StatefulWidget {
  const ContentChapterBookmarkPage({super.key});

  @override
  State<ContentChapterBookmarkPage> createState() =>
      _ContentChapterBookmarkPageState();
}

class _ContentChapterBookmarkPageState
    extends State<ContentChapterBookmarkPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  List<ChapterBookmarkData> list = [];
  bool isLoading = false;
  int currentSortId = 1;
  bool isAsc = true;
  List<TSort> sortList = [
    TSort(
      id: 1,
      title: 'Chapter',
      ascTitle: 'ငယ်စဥ်ကြီး',
      descTitle: 'ကြီးစဥ်ငယ်',
    ),
  ];

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });

      final novel = context.read<NovelProvider>().getCurrent;
      if (novel == null) return;
      final db = ChapterBookmarkDB.instance(novel.getChapterBookmarkPath);
      final res = await db.get();
      // filter
      list = res
          .where((e) => Chapter.isChapterExists(novel.path, e.chapter))
          .toList();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      _onSort();
    } catch (e) {
      NovelDirApp.showDebugLog(
        e.toString(),
        tag: 'ContentChapterBookmarkPage:init',
      );
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentImageWrapper(
      appBarAction: [
        _getSortAction(),
        IconButton(onPressed: _showMenu, icon: Icon(Icons.more_vert_rounded)),
      ],
      title: Text('Chapter Bookmark'),
      isLoading: isLoading,
      automaticallyImplyLeading: TPlatform.isDesktop,
      sliverBuilder: (context, novel) => [_getSliverList()],
      onRefresh: init,
    );
  }

  Widget _getSortAction() {
    return IconButton(
      onPressed: () {
        showTSortDialog(
          context,
          currentId: currentSortId,
          isAsc: isAsc,
          sortList: sortList,
          sortDialogCallback: (id, isAsc) {
            currentSortId = id;
            this.isAsc = isAsc;
            _onSort();
          },
        );
      },
      icon: Icon(Icons.sort),
    );
  }

  Widget _getEmptyListWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('List မရှိပါ...')],
      ),
    );
  }

  Widget _getSliverList() {
    if (list.isEmpty) {
      return SliverFillRemaining(child: _getEmptyListWidget());
    }
    return SliverList.separated(
      itemCount: list.length,
      itemBuilder: (context, index) => ChapterBookmarkListItem(
        bookmark: list[index],
        onClicked: (bookmark) => _goTextReader(bookmark),
        onRightClicked: _showItemMenu,
      ),
      separatorBuilder: (context, index) => Divider(),
    );
  }

  void _onSort() {
    list.sortChapter(isAsc: isAsc);
    setState(() {});
  }

  // main menu
  void _showMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        // ListTile(
        //   leading: Icon(Icons.add),
        //   title: Text('Add Chapter'),
        //   onTap: () {
        //     closeContext(context);
        //     _goEditChapter();
        //   },
        // ),
      ],
    );
  }

  // item menu
  void _showItemMenu(ChapterBookmarkData bookmark) {
    showTMenuBottomSheet(
      context,
      title: Text('Bookmark: ${bookmark.chapter}'),
      children: [
        // ListTile(
        //   leading: Icon(Icons.edit_document),
        //   title: Text('Edit'),
        //   onTap: () {
        //     closeContext(context);
        //     _goEditBookmark(bookmark);
        //   },
        // ),
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever_rounded),
          title: Text('Remove'),
          onTap: () {
            closeContext(context);
            _removeBookmark(bookmark);
          },
        ),
      ],
    );
  }

  void _removeBookmark(ChapterBookmarkData book) {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    // remove ui
    final index = list.indexWhere((e) => e.chapter == book.chapter);
    if (index == -1) return;
    list.removeAt(index);
    setState(() {});
    // remove db
    ChapterBookmarkDB.instance(
      novel.getChapterBookmarkPath,
    ).delete(index, book);
  }

  // void _goEditBookmark(ChapterBookmarkData book) {

  // }

  // go text reader
  void _goTextReader(ChapterBookmarkData bookmark) {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    final chapter = Chapter.createFromPath('${novel.path}/${bookmark.chapter}');
    if (chapter == null) {
      showTMessageDialogError(context, '`${bookmark.chapter}` မရှိပါ...');
      return;
    }
    goRoute(
      context,
      builder: (context) => ChapterReaderScreen(chapter: chapter),
    );
  }
}
