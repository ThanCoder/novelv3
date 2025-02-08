import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/components/novel_status_badge.dart';
import 'package:novel_v3/app/dialogs/novel_page_link_dialog.dart';
import 'package:novel_v3/app/dialogs/readed_edit_dialog.dart';
import 'package:novel_v3/app/enums/book_mark_sort_name.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/screens/chapter_text_reader_screen.dart';
import 'package:novel_v3/app/screens/novel_lib_screen.dart';
import 'package:novel_v3/app/screens/pdf_reader_screen.dart';
import 'package:novel_v3/app/services/app_services.dart';
import 'package:novel_v3/app/services/recent_db_services.dart';
import 'package:novel_v3/app/utils/app_util.dart';
import 'package:novel_v3/app/widgets/my_image_file.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:url_launcher/url_launcher.dart';

class NovelContentPage extends StatefulWidget {
  const NovelContentPage({super.key});

  @override
  State<NovelContentPage> createState() => NovelContentPageState();
}

class NovelContentPageState extends State<NovelContentPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() {
    if (currentNovelNotifier.value == null) return;
    currentNovelNotifier.value =
        NovelModel.fromPath(currentNovelNotifier.value!.path, isFullInfo: true);
  }

  void editReaded(int readed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReadedEditDialog(
        dialogContext: context,
        readed: readed,
      ),
    );
  }

  Widget getContentWidget(NovelModel novel) {
    final coverFile = File(novel.contentCoverPath);
    if (coverFile.existsSync()) {
      return MyImageFile(path: novel.contentCoverPath);
    }
    return Container();
  }

  bool isExistsFile(String path) {
    final file = File(path);
    return file.existsSync();
  }

  void _openPageUrl(String url) async {
    try {
      if (Platform.isAndroid) {
        await ThanPkg.platform.openUrl(url: url);
      } else {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          showMessage(
              context, 'Url မဖွင့်နိုင်ဘူး! ဒါကြောင့် copy ကူးပေးလိုက်ပါတယ်');
          copyText(url);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _showPageDialog(String pageUrl) {
    try {
      //show page dialog
      showDialog(
        context: context,
        builder: (context) => NovelPageLinkDialog(
          dialogContext: context,
          pageUrl: pageUrl,
          onClick: _openPageUrl,
        ),
      );
    } catch (e) {
      debugPrint('openPageUrl: ${e.toString()}');
    }
  }

  Widget getRecentTextButton(NovelModel novel) {
    final chapterTitle = getRecentDB<String>(
            'chapter_list_page_${currentNovelNotifier.value!.title}') ??
        '';
    final file = File('${currentNovelNotifier.value!.path}/$chapterTitle');
    if (file.existsSync()) {
      return ElevatedButton(
        onPressed: () {
          //go reader
          currentChapterNotifier.value = ChapterModel.fromFile(file);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChapterTextReaderScreen(),
            ),
          );
        },
        child: const Text('Recent Text'),
      );
    }
    return Container();
  }

  Widget getRecentPdfButton(NovelModel novel) {
    final pdfTitle = getRecentDB<String>(
            'pdf_list_page_${currentNovelNotifier.value!.title}') ??
        '';
    final file = File('${currentNovelNotifier.value!.path}/$pdfTitle');
    if (file.existsSync()) {
      return ElevatedButton(
        onPressed: () {
          //go reader
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PdfReaderScreen(pdfFile: PdfFileModel.fromPath(file.path)),
            ),
          );
        },
        child: const Text('Recent PDF'),
      );
    }
    return Container();
  }

  Widget getPageButton(NovelModel novel) {
    return isExistsFile('${novel.path}/link')
        ? ElevatedButton(
            onPressed: () {
              _showPageDialog('${novel.path}/link');
            },
            child: const Text('Go Page'),
          )
        : Container();
  }

  Widget getStartButton(NovelModel novel) {
    return isExistsFile('${novel.path}/1')
        ? ElevatedButton(
            onPressed: () {
              final chapter = ChapterModel.fromPath('${novel.path}/1');
              currentChapterNotifier.value = chapter;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChapterTextReaderScreen(),
                ),
              );
            },
            child: const Text('Start Read'),
          )
        : Container();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goNovelLibPage(BookMarkSortName bmsn) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelLibScreen(
          bookMarkSortName: bmsn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentNovelNotifier,
      builder: (context, novel, child) {
        if (novel == null) {
          return const Center(
            child: Text('Novel မရှိပါ'),
          );
        } else {
          return ListView(
            controller: _scrollController,
            children: [
              //novel header
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 180,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: MyImageFile(path: novel.coverPath)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //title
                      TextButton(
                        onPressed: () {
                          copyText(novel.title);
                        },
                        child: Text(
                          novel.title,
                          maxLines: 3,
                          style: const TextStyle(
                            fontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      //readed
                      TextButton(
                        onPressed: () {
                          editReaded(novel.readed);
                        },
                        child: Text('Readed: ${novel.readed.toString()}'),
                      ),
                      //Author
                      TextButton(
                        onPressed: () {},
                        child: Text('Author: ${novel.author}'),
                      ),
                      //mc
                      TextButton(
                        onPressed: () {},
                        child: Text('MC: ${novel.mc}'),
                      ),

                      //date
                      TextButton(
                          onPressed: () {},
                          child: Text('Date: ${getParseDate(novel.date)}')),
                      const SizedBox(height: 20),
                      Wrap(
                        children: [
                          novel.isAdult
                              ? NovelStatusBadge(
                                  onClick: (text) {
                                    _goNovelLibPage(
                                        BookMarkSortName.novleAdult);
                                  },
                                  text: 'Adult Novel',
                                  bgColor: Colors.red,
                                )
                              : Container(),
                          const SizedBox(width: 10),
                          NovelStatusBadge(
                            onClick: (text) {
                              if (text == 'Completed') {
                                _goNovelLibPage(
                                    BookMarkSortName.novelIsCompleted);
                              } else if (text == 'OnGoing') {
                                _goNovelLibPage(BookMarkSortName.novelOnGoing);
                              }
                            },
                            text: novel.isCompleted ? 'Completed' : 'OnGoing',
                            bgColor: novel.isCompleted
                                ? Colors.blue[900]
                                : Colors.teal[900],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              //go page
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 10,
                  children: [
                    //page
                    getPageButton(novel),
                    //start Chapter
                    getStartButton(novel),
                    //recent go page
                    getRecentTextButton(novel),
                    //recent pdf
                    getRecentPdfButton(novel),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              //des
              //content cover
              getContentWidget(novel),
              //text
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableText(
                  novel.content,
                  style: Platform.isLinux
                      ? Theme.of(context).textTheme.bodyLarge
                      : Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 50),
            ],
          );
        }
      },
    );
  }
}
