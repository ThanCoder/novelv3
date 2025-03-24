import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/components/novel_content/index.dart';
import 'package:novel_v3/app/components/novel_status_badge.dart';
import 'package:novel_v3/app/dialogs/novel_page_link_dialog.dart';
import 'package:novel_v3/app/dialogs/rename_dialog.dart';
import 'package:novel_v3/app/enums/book_mark_sort_name.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:novel_v3/app/utils/app_util.dart';
import 'package:provider/provider.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../screens/index.dart';
import '../../widgets/index.dart';

class NovelContentPage extends StatefulWidget {
  const NovelContentPage({super.key});

  @override
  State<NovelContentPage> createState() => NovelContentPageState();
}

class NovelContentPageState extends State<NovelContentPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(_onListViewScroll);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  void init() {
    // if (currentNovelNotifier.value == null) return;
    // currentNovelNotifier.value =
    //     NovelModel.fromPath(, isFullInfo: true);
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

  //dialog
  void editReaded(int readed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RenameDialog(
        title: 'Readed',
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputType: TextInputType.number,
        text: readed.toString(),
        onCancel: () {},
        onSubmit: (text) {
          try {
            if (int.tryParse(text) == null) {
              showMessage(context, 'readed number ထည့်သွင်းပေးပါ!');
              return;
            }

            final novel = currentNovelNotifier.value;
            int num = int.parse(text);
            //check
            if (novel == null) {
              showMessage(context, 'novel is null!');
              return;
            }
            //no error
            novel.readed = num;

            //change data
            updateNovelReaded(novel: novel);
            //change ui
            currentNovelNotifier.value = null;
            currentNovelNotifier.value = novel;
            context
                .read<NovelProvider>()
                .setCurrentNovel(novelSourcePath: novel.path);
          } catch (e) {
            showMessage(context, e.toString());
          }
        },
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
    final file = File(pageUrl);
    final content = file.readAsStringSync();
    if (content.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => NovelPageLinkDialog(
        pageUrl: content,
        onClick: _openPageUrl,
      ),
    );
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
        child: const Text('မကြာခင်က Text'),
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
        child: const Text('မကြာခင်က PDF'),
      );
    }
    return Container();
  }

  Widget getPageButton(NovelModel novel) {
    final file = File('${novel.path}/link');
    if (file.existsSync() && file.readAsStringSync().isNotEmpty) {
      return ElevatedButton(
        onPressed: () {
          _showPageDialog('${novel.path}/link');
        },
        child: const Text('Go Page'),
      );
    }
    return const SizedBox.shrink();
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
    final novelProvider = context.watch<NovelProvider>();
    final isLoading = novelProvider.isLoading;
    final novel = novelProvider.getNovel;
    if (isLoading) {
      return Center(child: TLoader());
    }
    if (novel == null) {
      return const Center(
        child: Text('Novel မရှိပါ'),
      );
    } else {
      return GestureDetector(
        onTap: () {
          if (!isShowContentBottomBarNotifier.value) {
            isShowContentBottomBarNotifier.value = true;
          }
        },
        child: ListView(
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
                    child: MyImageFile(
                      path: novel.coverPath,
                      fit: BoxFit.fill,
                    ),
                  ),
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
                      child: Text(
                        'Readed: ${novel.readed.toString()}',
                        style: const TextStyle(color: Colors.teal),
                      ),
                    ),
                    //Author
                    TextButton(
                      onPressed: () {},
                      child: Text('Author: ${novel.author}'),
                    ),
                    //mc
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NovelMcSearchScreen(mcName: novel.mc),
                          ),
                        );
                      },
                      child: Text('MC: ${novel.mc}'),
                    ),

                    //date
                    TextButton(
                        onPressed: () {},
                        child: Text(
                            'Date: ${AppUtil.instance.getParseDate(novel.date)}')),
                    const SizedBox(height: 20),
                    Wrap(
                      children: [
                        novel.isAdult
                            ? NovelStatusBadge(
                                onClick: (text) {
                                  _goNovelLibPage(BookMarkSortName.novleAdult);
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
                  //readed
                  NovelContentReadedBotttom(novel: novel),
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
                style: const TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      );
    }
  }
}
