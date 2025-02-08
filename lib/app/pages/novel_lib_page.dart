import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_list_view.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/screens/novel_content_screen.dart';
import 'package:novel_v3/app/services/novel_bookmark_services.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';

enum _BookMarkSortName {
  novelBookMark,
  novleAdult,
  novelOnGoing,
  novelIsCompleted,
}

class NovelLibPage extends StatefulWidget {
  const NovelLibPage({super.key});

  @override
  State<NovelLibPage> createState() => _NovelLibPageState();
}

class _NovelLibPageState extends State<NovelLibPage> {
  @override
  void initState() {
    init();
    super.initState();
  }

  bool isLoading = false;
  _BookMarkSortName _bookMarkSortName = _BookMarkSortName.novelBookMark;

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
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  void sortNovel(_BookMarkSortName name) {
    try {
      setState(() {
        isLoading = true;
      });
      //book mark
      if (name == _BookMarkSortName.novelBookMark) {
        novelBookMarkListNotifier.value = [];
        final bmList = getNovelBookmarkList();
        final novelList =
            bmList.map((bm) => NovelModel.fromPath(bm.path)).toList();
        novelBookMarkListNotifier.value = novelList;
      }
      //is Adult
      if (name == _BookMarkSortName.novleAdult) {
        novelBookMarkListNotifier.value =
            novelListNotifier.value.where((nv) => nv.isAdult).toList();
      }
      //is ongoing
      if (name == _BookMarkSortName.novelOnGoing) {
        novelBookMarkListNotifier.value =
            novelListNotifier.value.where((nv) => !nv.isCompleted).toList();
      }
      //is completed
      if (name == _BookMarkSortName.novelIsCompleted) {
        novelBookMarkListNotifier.value =
            novelListNotifier.value.where((nv) => nv.isCompleted).toList();
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
    return Padding(
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
              _TChip(
                title: 'BookMark',
                avatar: _bookMarkSortName == _BookMarkSortName.novelBookMark
                    ? const Icon(Icons.check)
                    : null,
                onClick: () {
                  sortNovel(_BookMarkSortName.novelBookMark);
                  setState(() {
                    _bookMarkSortName = _BookMarkSortName.novelBookMark;
                  });
                },
              ),
              _TChip(
                title: 'Adult',
                avatar: _bookMarkSortName == _BookMarkSortName.novleAdult
                    ? const Icon(Icons.check)
                    : null,
                onClick: () {
                  sortNovel(_BookMarkSortName.novleAdult);
                  setState(() {
                    _bookMarkSortName = _BookMarkSortName.novleAdult;
                  });
                },
              ),
              _TChip(
                title: 'OnGoing',
                avatar: _bookMarkSortName == _BookMarkSortName.novelOnGoing
                    ? const Icon(Icons.check)
                    : null,
                onClick: () {
                  sortNovel(_BookMarkSortName.novelOnGoing);
                  setState(() {
                    _bookMarkSortName = _BookMarkSortName.novelOnGoing;
                  });
                },
              ),
              _TChip(
                title: 'Completed',
                avatar: _bookMarkSortName == _BookMarkSortName.novelIsCompleted
                    ? const Icon(Icons.check)
                    : null,
                onClick: () {
                  sortNovel(_BookMarkSortName.novelIsCompleted);
                  setState(() {
                    _bookMarkSortName = _BookMarkSortName.novelIsCompleted;
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
                            _bookMarkSortName = _BookMarkSortName.novelBookMark;
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
                        builder: (context) => NovelContentScreen(novel: novel),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TChip extends StatelessWidget {
  String title;
  Widget? avatar;
  void Function()? onClick;
  void Function()? onDelete;
  _TChip({
    super.key,
    required this.title,
    this.avatar,
    this.onClick,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Chip(
        label: Text(title),
        avatar: avatar,
        onDeleted: onDelete,
      ),
    );
  }
}
