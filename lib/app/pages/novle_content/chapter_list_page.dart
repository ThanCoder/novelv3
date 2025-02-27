import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:novel_v3/app/components/chapter_list_view.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/provider/chapter_provider.dart';
import 'package:novel_v3/app/screens/novel_screens/chapter_text_reader_screen.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:provider/provider.dart';

import '../../widgets/index.dart';

class ChapterListPage extends StatefulWidget {
  const ChapterListPage({super.key});

  @override
  State<ChapterListPage> createState() => ChapterListPageState();
}

class ChapterListPageState extends State<ChapterListPage> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    _scrollController.addListener(_onListViewScroll);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
      //show default
      isShowContentBottomBarNotifier.value = true;
    });
  }

  bool isSorted = true;
  ChapterModel? selectedChapter;

  void init() {
    if (currentNovelNotifier.value == null) return;
    context.read<ChapterProvider>().initList();
  }

  void _onListViewScroll() {
    //down
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      isShowContentBottomBarNotifier.value = false;
    }
    //up
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      isShowContentBottomBarNotifier.value = true;
    }
  }

  void openMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {},
        builder: (context) => Column(
          children: [
            Text('Chapter ${selectedChapter!.title}'),
            ListTile(
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _deleteChapter();
              },
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
            )
          ],
        ),
      ),
    );
  }

  void _deleteChapter() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText:
            'Chapter ${selectedChapter!.title} ကိုဖျက်ချင်တာ သေချာပြီလား?',
        cancelText: 'No',
        submitText: 'Yes',
        onCancel: () {},
        onSubmit: () {
          if (selectedChapter != null) {
            deleteChapter(chapter: selectedChapter!);
          }
        },
      ),
    );
  }

  void _goChapterReaderScreen(ChapterModel chapter) {
    //set recent
    setRecentDB('chapter_list_page_${currentNovelNotifier.value!.title}',
        chapter.title);
    setState(() {});
    currentChapterNotifier.value = chapter;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChapterTextReaderScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChapterProvider>();
    final isLoading = provider.isLoading;
    final chapterList = provider.getList;

    if (isLoading) {
      return Center(
        child: TLoader(),
      );
    }
    if (chapterList.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Chapter List မရှိပါ"),
          IconButton(
            color: Colors.teal[900],
            onPressed: init,
            icon: const Icon(Icons.refresh),
          ),
        ],
      );
    }
    return Column(
      children: [
        //top bar
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            chapterList.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isSorted = !isSorted;
                      });
                      context.read<ChapterProvider>().reversed();
                    },
                    icon: Icon(
                      isSorted ? Icons.arrow_downward : Icons.arrow_upward,
                    ),
                  )
                : Container(),
          ],
        ),
        const Divider(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 800));
              init();
            },
            child: ChapterListView(
              controller: _scrollController,
              chapterList: chapterList,
              isSelected: true,
              selectedTitle: getRecentDB<String>(
                      'chapter_list_page_${currentNovelNotifier.value!.title}') ??
                  '',
              onClick: _goChapterReaderScreen,
              onLongClick: (chapter) {
                selectedChapter = chapter;
                openMenu();
              },
            ),
          ),
        ),
      ],
    );
  }
}
