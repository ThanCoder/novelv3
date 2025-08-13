import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/chapter_list_item.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:novel_v3/app/screens/chapter_reader/chapter_reader_screen.dart';
import 'package:novel_v3/app/screens/forms/edit_chapter_screen.dart';
import 'package:novel_v3/more_libs/sort_dialog_v1.0.0/sort_component.dart';
import 'package:novel_v3/more_libs/sort_dialog_v1.0.0/sort_type.dart';
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
        _getSortAciton(),
        IconButton(onPressed: _showMenu, icon: Icon(Icons.more_vert_rounded)),
      ],
      title: Text('Chapter'),
      isLoading: isLoading,
      automaticallyImplyLeading: PlatformExtension.isDesktop(),
      sliverBuilder: (context, novel) => [_getSliverList(list)],
      onRefresh: init,
    );
  }

  Widget _getSortAciton() {
    return SortComponent(
      sortList: [SortType(title: 'chapter', isAsc: true)],
      value: context.watch<ChapterProvider>().sortType,
      onChanged: (type) {
        context.read<ChapterProvider>().sortList(type);
      },
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
      ],
    );
  }

  void _goEditChapter() {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    goRoute(
      context,
      builder: (context) => EditChapterScreen(novelPath: novel.path),
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
    goRoute(
      context,
      builder: (context) => ChapterReaderScreen(
        chapter: chapter,
        onReadedLastChapter: _checkLastChapter,
      ),
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
