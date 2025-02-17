import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_list_view.dart';
import 'package:novel_v3/app/enums/book_mark_sort_name.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:novel_v3/app/screens/novel_content_screen.dart';
import 'package:novel_v3/app/services/novel_bookmark_services.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';
import 'package:novel_v3/app/widgets/t_chip.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';
import 'package:provider/provider.dart';

class NovelLibPage extends StatefulWidget {
  BookMarkSortName bookMarkSortName;
  NovelLibPage({
    super.key,
    this.bookMarkSortName = BookMarkSortName.novelBookMark,
  });

  @override
  State<NovelLibPage> createState() => _NovelLibPageState();
}

class _NovelLibPageState extends State<NovelLibPage> {
  @override
  void initState() {
    bookMarkSortName = widget.bookMarkSortName;
    super.initState();
    init();
  }

  bool isLoading = false;
  late BookMarkSortName bookMarkSortName;

  void init() {
    try {
      setState(() {
        isLoading = true;
      });
      novelBookMarkListNotifier.value = [];
      final bmList = getNovelBookmarkList();
      final novelList =
          bmList.map((bm) => NovelModel.fromPath(bm.path)).toList();
      novelBookMarkListNotifier.value = novelList;

      setState(() {
        isLoading = false;
      });
      _sortNovel(bookMarkSortName);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  void _sortNovel(BookMarkSortName name) {
    try {
      final novelList = context.read<NovelProvider>().getList;
      setState(() {
        isLoading = true;
      });
      //book mark
      if (name == BookMarkSortName.novelBookMark) {
        novelBookMarkListNotifier.value = [];
        final bmList = getNovelBookmarkList();
        final novelList =
            bmList.map((bm) => NovelModel.fromPath(bm.path)).toList();
        novelBookMarkListNotifier.value = novelList;
      }
      //is Adult
      if (name == BookMarkSortName.novleAdult) {
        novelBookMarkListNotifier.value =
            novelList.where((nv) => nv.isAdult).toList();
      }
      //is ongoing
      if (name == BookMarkSortName.novelOnGoing) {
        novelBookMarkListNotifier.value =
            novelList.where((nv) => !nv.isCompleted).toList();
      }
      //is completed
      if (name == BookMarkSortName.novelIsCompleted) {
        novelBookMarkListNotifier.value =
            novelList.where((nv) => nv.isCompleted).toList();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: TLoader());
    }
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //sort list
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              alignment: WrapAlignment.start,
              spacing: 10,
              runSpacing: 10,
              children: [
                TChip(
                  title: 'BookMark',
                  avatar: bookMarkSortName == BookMarkSortName.novelBookMark
                      ? const Icon(Icons.check)
                      : null,
                  onClick: () {
                    _sortNovel(BookMarkSortName.novelBookMark);
                    setState(() {
                      bookMarkSortName = BookMarkSortName.novelBookMark;
                    });
                  },
                ),
                TChip(
                  title: 'Adult',
                  avatar: bookMarkSortName == BookMarkSortName.novleAdult
                      ? const Icon(Icons.check)
                      : null,
                  onClick: () {
                    _sortNovel(BookMarkSortName.novleAdult);
                    setState(() {
                      bookMarkSortName = BookMarkSortName.novleAdult;
                    });
                  },
                ),
                TChip(
                  title: 'OnGoing',
                  avatar: bookMarkSortName == BookMarkSortName.novelOnGoing
                      ? const Icon(Icons.check)
                      : null,
                  onClick: () {
                    _sortNovel(BookMarkSortName.novelOnGoing);
                    setState(() {
                      bookMarkSortName = BookMarkSortName.novelOnGoing;
                    });
                  },
                ),
                TChip(
                  title: 'Completed',
                  avatar: bookMarkSortName == BookMarkSortName.novelIsCompleted
                      ? const Icon(Icons.check)
                      : null,
                  onClick: () {
                    _sortNovel(BookMarkSortName.novelIsCompleted);
                    setState(() {
                      bookMarkSortName = BookMarkSortName.novelIsCompleted;
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: novelBookMarkListNotifier,
                builder: (context, value, child) {
                  if (value.isEmpty) {
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Novel List မရှိပါ'),
                        IconButton(
                          color: Colors.teal,
                          onPressed: () {
                            setState(() {
                              bookMarkSortName = BookMarkSortName.novelBookMark;
                            });
                            init();
                          },
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ));
                  }
                  return NovelListView(
                    novelList: value,
                    onClick: (novel) {
                      currentNovelNotifier.value = novel;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NovelContentScreen(novel: novel),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
