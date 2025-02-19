import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/chapter_book_mark_list_view.dart';
import 'package:novel_v3/app/models/chapter_book_mark_model.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/screens/index.dart';
import 'package:novel_v3/app/services/novel_services.dart';
import 'package:provider/provider.dart';

import '../provider/index.dart';

class NovelBookMarkListPage extends StatefulWidget {
  const NovelBookMarkListPage({super.key});

  @override
  State<NovelBookMarkListPage> createState() => NovelBookMarkListPageState();
}

class NovelBookMarkListPageState extends State<NovelBookMarkListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    init();
    super.initState();
  }

  bool isSorted = true;

  void init() {
    if (currentNovelNotifier.value == null) return;
    getBookMarkList(
      sourcePath: currentNovelNotifier.value!.path,
      onSuccess: (chapterBookList) {
        chapterBookMarkListNotifier.value = chapterBookList;
      },
      onError: (err) {
        debugPrint(err);
      },
    );
  }

  void onClick(ChapterBookMarkModel bookMark) {
    //get chapter path
    final path = currentNovelNotifier.value!.path;
    final file = File('$path/${bookMark.chapter}');
    currentChapterNotifier.value = ChapterModel.fromFile(file);

    if (chapterListNotifier.value.isEmpty) {
      context.read<ChapterProvider>().getList;
    } else {
      //go reader
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChapterTextReaderScreen(),
        ),
      );
    }
  }

  void onLongClick(ChapterBookMarkModel bookMark) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: [
          ListTile(
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              _removeBookMark(bookMark.title);
            },
            leading: const Icon(Icons.delete_forever),
            title: const Text('Remove'),
          )
        ],
      ),
    );
  }

  void _removeBookMark(String title) {
    //remove data
    removeBookMark(
      sourcePath: currentNovelNotifier.value!.path,
      title: title,
      onSuccess: () {
        //update ui
        final list = chapterBookMarkListNotifier.value
            .where((bm) => bm.title != title)
            .toList();
        chapterBookMarkListNotifier.value = list;
      },
      onError: (err) {
        debugPrint(err);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: chapterBookMarkListNotifier,
      builder: (context, value, child) {
        return Column(
          children: [
            //top bar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                value.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            isSorted = !isSorted;
                          });
                          chapterBookMarkListNotifier.value =
                              chapterBookMarkListNotifier.value.reversed
                                  .toList();
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
                child: ChapterBookMarkListView(
                  controller: _scrollController,
                  bookList: value,
                  onClick: onClick,
                  onLongClick: onLongClick,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
