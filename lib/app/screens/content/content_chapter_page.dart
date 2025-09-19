import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/chapter_list_item.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:novel_v3/app/screens/content/page_url_dialog.dart';
import 'package:novel_v3/app/screens/forms/edit_chapter_screen.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/fetch_send_data.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/screens/fetcher_chapter_list_screen.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/screens/fetcher_chapter_screen.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/extensions/index.dart';

import '../../novel_dir_app.dart';
import 'content_image_wrapper.dart';

class ContentChapterPage extends StatefulWidget {
  const ContentChapterPage({super.key});

  @override
  State<ContentChapterPage> createState() => _ContentChapterPageState();
}

class _ContentChapterPageState extends State<ContentChapterPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    await context.read<ChapterProvider>().initList(novel.path);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChapterProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;

    return ContentImageWrapper(
      appBarAction: [
        _getSortAction(),
        IconButton(onPressed: _showMenu, icon: Icon(Icons.more_vert_rounded)),
      ],
      title: Text('Chapter'),
      isLoading: isLoading,
      automaticallyImplyLeading: TPlatform.isDesktop,
      sliverBuilder: (context, novel) => [_getSliverList(list)],
      onRefresh: init,
    );
  }

  Widget _getSortAction() {
    final provider = context.read<ChapterProvider>();
    return IconButton(
      onPressed: () {
        showTSortDialog(
          context,
          currentId: provider.currentSortId,
          isAsc: provider.isSortAsc,
          sortList: provider.getSortList,
          sortDialogCallback: (id, isAsc) {
            provider.setSort(id, isAsc);
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
        children: [
          Text('List မရှိပါ...'),
          IconButton(
            color: Colors.blue,
            onPressed: _goEditChapter,
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _getSliverList(List<Chapter> list) {
    if (list.isEmpty) {
      return SliverFillRemaining(child: _getEmptyListWidget());
    }
    return SliverList.separated(
      itemCount: list.length,
      itemBuilder: (context, index) => ChapterListItem(
        chapter: list[index],
        onClicked: (chapter) => _goTextReader(chapter),
        onRightClicked: _showItemMenu,
      ),
      separatorBuilder: (context, index) => Divider(),
    );
  }

  // main menu
  void _showMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Chapter'),
          onTap: () {
            closeContext(context);
            _goEditChapter();
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Chapter With Online'),
          onTap: () {
            closeContext(context);
            _goFetcher();
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Multi Chapter With Online'),
          onTap: () {
            closeContext(context);

            _goMultiChapterFetcher();
          },
        ),
      ],
    );
  }

  void _goEditChapter({Chapter? chapter}) {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    goRoute(
      context,
      builder: (context) => EditChapterScreen(
        novelPath: novel.path,
        chapter: chapter,
        onClosed: () {
          init();
        },
      ),
    );
  }

  void _goFetcher() {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    final latestChapter = context.read<ChapterProvider>().getLatestChapter;
    goRoute(
      context,
      builder: (context) => FetcherChapterScreen(
        fetchSendData: FetchSendData(url: '', chapterNumber: latestChapter + 1),
        onReceiveData: (context, receiveData) async {
          try {
            final chapter = Chapter.createPath(
              '${novel.path}/${receiveData.chapterNumber}',
            );
            await chapter.setContent(receiveData.contentText);
            if (!context.mounted) return;

            showTSnackBar(context, 'Added Chapter:${chapter.number}');
          } catch (e) {
            Setting.showDebugLog(
              e.toString(),
              tag: 'ContentChapterPage:onReceiveData',
            );
          }
        },
        onClosed: init,
      ),
    );
  }

  void _goMultiChapterFetcher() {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    showDialog(
      context: context,
      builder: (context) => PageUrlDialog(
        list: novel.getPageUrls,
        onClicked: (url) {
          goRoute(
            context,
            builder: (context) => FetcherChapterListScreen(
              sourceDirPath: novel.path,
              pageUrl: url,
              onClosed: () => init(),
            ),
          );
        },
        onSubmit: () {
          goRoute(
            context,
            builder: (context) => FetcherChapterListScreen(
              sourceDirPath: novel.path,
              onClosed: () => init(),
            ),
          );
        },
      ),
    );
  }

  // item menu
  void _showItemMenu(Chapter chapter) {
    showTMenuBottomSheet(
      context,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Chapter: ${chapter.number}'),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit_document),
          title: Text('Edit'),
          onTap: () {
            closeContext(context);
            _goEditChapter(chapter: chapter);
          },
        ),
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever_rounded),
          title: Text('Delete Forever!'),
          onTap: () {
            closeContext(context);
            _deleteForever(chapter);
          },
        ),
      ],
    );
  }

  void _deleteForever(Chapter chapter) {
    context.read<ChapterProvider>().delete(chapter);
  }

  // go text reader
  void _goTextReader(Chapter chapter) {
    goChapterReader(
      context,
      chapter: chapter,
      onReaderClosed: _checkLastChapter,
    );
  }

  void _checkLastChapter(Chapter chapter) {
    try {
      final novel = context.read<NovelProvider>().getCurrent;
      if (novel == null) return;
      final readed = novel.getReadedNumber;
      if (chapter.number <= readed) return;
      //ကြီးနေတယ်ဆိုရင်
      showTConfirmDialog(
        context,
        barrierDismissible: false,
        title: 'Readed ကိုသိမ်းဆည်းချင်ပါသလား?',
        contentText:
            'သိမ်းဆည်းထားသော Chapter:`$readed`\nဖတ်ပြီးသွားတဲ့ Chapter:`${chapter.number}`',
        submitText: 'သိမ်းမယ်',
        cancelText: 'မသိမ်းဘူး',
        onSubmit: () {
          novel.setReaded(chapter.number.toString());
          setState(() {});
        },
      );
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString());
    }
  }
}
