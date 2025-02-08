import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/components/chapter_list_view.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/screens/chapter_text_reader_screen.dart';
import 'package:novel_v3/app/services/novel_isolate_services.dart';
import 'package:novel_v3/app/services/novel_services.dart';
import 'package:novel_v3/app/services/recent_db_services.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';

class ChapterListPage extends StatefulWidget {
  void Function(PdfFileModel pdfFile)? onClick;
  void Function(PdfFileModel pdfFile)? onLongClick;
  ChapterListPage({super.key, this.onClick, this.onLongClick});

  @override
  State<ChapterListPage> createState() => ChapterListPageState();
}

class ChapterListPageState extends State<ChapterListPage> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    init();
    super.initState();
  }

  bool isSorted = true;
  bool isLoading = false;
  ChapterModel? selectedChapter;

  void init() {
    if (currentNovelNotifier.value == null) return;
    setState(() {
      isLoading = true;
    });
    chapterListNotifier.value = [];

    getChapterListFromPathIsolate(
      novelSourcePath: currentNovelNotifier.value!.path,
      onSuccess: (chapterList) {
        chapterListNotifier.value = chapterList;
        setState(() {
          isLoading = false;
        });
      },
      onError: (err) {
        setState(() {
          isLoading = false;
        });
        showMessage(context, err);
        debugPrint(err);
      },
    );
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
    if (isLoading) {
      return Center(
        child: TLoader(),
      );
    } else {
      return ValueListenableBuilder(
        valueListenable: chapterListNotifier,
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
                            chapterListNotifier.value =
                                chapterListNotifier.value.reversed.toList();
                          },
                          icon: Icon(
                            isSorted
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
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
                    chapterList: value,
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
        },
      );
    }
  }
}
