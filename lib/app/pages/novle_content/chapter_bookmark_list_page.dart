import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/chapter_book_mark_list_view.dart';
import 'package:novel_v3/app/models/chapter_book_mark_model.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/provider/chapter_bookmark_provider.dart';
import 'package:novel_v3/app/screens/index.dart';
import 'package:novel_v3/app/widgets/index.dart';
import 'package:provider/provider.dart';

class ChapterBookmarkListPage extends StatefulWidget {
  const ChapterBookmarkListPage({super.key});

  @override
  State<ChapterBookmarkListPage> createState() =>
      ChapterBookmarkListPageState();
}

class ChapterBookmarkListPageState extends State<ChapterBookmarkListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isSorted = true;

  void init() async {
    await context.read<ChapterBookmarkProvider>().initList();
  }

  void onClick(ChapterBookMarkModel bookMark) {
    //get chapter path
    final path = currentNovelNotifier.value!.path;
    final file = File('$path/${bookMark.chapter}');
    currentChapterNotifier.value = ChapterModel.fromFile(file);

    //go reader
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChapterTextReaderScreen(),
      ),
    );
  }

  void _showMenu(ChapterBookMarkModel bookMark) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 150),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<ChapterBookmarkProvider>()
                      .update(context, bookmark: bookMark);
                },
              ),
              ListTile(
                textColor: Colors.red,
                iconColor: Colors.red,
                leading: const Icon(Icons.delete_forever),
                title: const Text('Remove'),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<ChapterBookmarkProvider>()
                      .delete(bookmark: bookMark);
                },
              ),
            ],
          ),
        ),
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
    final provider = context.watch<ChapterBookmarkProvider>();
    final list = provider.getList;
    final isLoading = provider.isLoading;
    if (isLoading) {
      return TLoader();
    }
    return Column(
      children: [
        //top bar
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            list.isNotEmpty && list.length > 1
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isSorted = !isSorted;
                      });
                      chapterBookMarkListNotifier.value =
                          chapterBookMarkListNotifier.value.reversed.toList();
                    },
                    icon: Icon(
                      isSorted ? Icons.arrow_downward : Icons.arrow_upward,
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        list.isNotEmpty && list.length > 1
            ? const Divider()
            : const SizedBox.shrink(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 800));
              init();
            },
            child: ChapterBookMarkListView(
              controller: _scrollController,
              bookList: list,
              onClick: onClick,
              onLongClick: _showMenu,
            ),
          ),
        ),
      ],
    );
  }
}
