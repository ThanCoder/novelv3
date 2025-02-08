import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/dialogs/text_reader_config_dialog.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/models/text_reader_config_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/services/app_services.dart';
import 'package:novel_v3/app/services/novel_services.dart';
import 'package:novel_v3/app/services/recent_db_services.dart';
import 'package:novel_v3/app/services/text_reader_services.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';

class ChapterTextReaderScreen extends StatefulWidget {
  const ChapterTextReaderScreen({super.key});

  @override
  State<ChapterTextReaderScreen> createState() =>
      _ChapterTextReaderScreenState();
}

class _ChapterTextReaderScreenState extends State<ChapterTextReaderScreen> {
  bool isLoading = false;
  bool isShowBottomChapterNavBar = false;
  ScrollController scrollController = ScrollController();
  bool isFullScreen = false;
  late TextReaderConfigModel readerConfig;
  int lastChapterNumber = 0;
  int firstChapterNumber = 0;
  int currentChapterNumber = 0;
  late ChapterModel currentChapter;

  int getPositionFromList(String title) {
    return chapterListNotifier.value.indexWhere((c) => c.title == title);
  }

  @override
  void initState() {
    scrollController.addListener(_scroll);
    super.initState();
    init();
  }

  void init() {
    try {
      readerConfig = getTextReaderConfig();

      //keep screen
      _androidKeepScreen(readerConfig.isKeepScreen);

      getFirstChapterListFromPath(
        novelSourcePath: currentNovelNotifier.value!.path,
        onSuccess: (number) {
          firstChapterNumber = number;
        },
      );
      getLastChapterListFromPath(
        novelSourcePath: currentNovelNotifier.value!.path,
        onSuccess: (number) {
          lastChapterNumber = number;
        },
      );
      if (currentChapterNotifier.value != null) {
        currentChapterNumber = int.parse(currentChapterNotifier.value!.title);
        currentChapter = currentChapterNotifier.value!;
      }
    } catch (e) {
      debugPrint('init: ${e.toString()}');
    }
  }

  void _androidKeepScreen(bool isKeep) async {
    toggleAndroidKeepScreen(isKeep);
  }

  void _scroll() {
    if (!isShowBottomChapterNavBar &&
        scrollController.position.maxScrollExtent > 200) {
      setState(() {
        isShowBottomChapterNavBar = true;
      });
    }
    if (isShowBottomChapterNavBar &&
        scrollController.position.maxScrollExtent < 200) {
      setState(() {
        isShowBottomChapterNavBar = false;
      });
    }
  }

  void _nextChapter() async {
    try {
      setState(() {
        currentChapterNumber++;
      });
      if (currentChapterNumber == 0 ||
          currentChapterNumber > lastChapterNumber) {
        showMessage(
            context, 'chapter "${currentChapterNumber.toString()}" မရှိပါ');
        currentChapterNumber--;
        return;
      }

      loadedChapter();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _prevChapter() async {
    try {
      setState(() {
        currentChapterNumber--;
      });

      if (currentChapterNumber == 0 ||
          currentChapterNumber < firstChapterNumber) {
        showMessage(
            context, 'chapter "${currentChapterNumber.toString()}" မရှိပါ');
        currentChapterNumber++;
        return;
      }

      loadedChapter();

      isLoading = false;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void loadedChapter() async {
    try {
      final path = '${currentNovelNotifier.value!.path}/$currentChapterNumber';
      final file = File(path);
      if (!file.existsSync()) {
        showMessage(
            context, 'chapter "${currentChapterNumber.toString()}" မရှိပါ');
        return;
      }
      //exists
      currentChapter = ChapterModel.fromPath(path);
      //set recent db
      setRecentDB('chapter_list_page_${currentNovelNotifier.value!.title}',
          currentChapter.title);

      await Future.delayed(const Duration(milliseconds: 200));
      scrollController.jumpTo(0);
    } catch (e) {
      debugPrint('loadedChapter: ${e.toString()}');
    }
  }

  void showSettingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TextReaderConfigDialog(
        dialogContext: context,
        readerConfig: readerConfig,
        submitText: 'Apply',
        onCancel: () {},
        onSubmit: (TextReaderConfigModel _readerConfig) {
          setState(() {
            readerConfig = _readerConfig;
          });
          //save config
          setTextReaderConfig(readerConfig);
          //android keep screen
          _androidKeepScreen(_readerConfig.isKeepScreen);
        },
      ),
    );
  }

  void showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 200,
        child: ListView(
          children: [
            //add chapter
            ListTile(
              onTap: () {
                Navigator.pop(context);
                showSettingDialog();
              },
              leading: const Icon(Icons.settings),
              title: const Text('Setting'),
            ),
          ],
        ),
      ),
    ).then((val) {
      print('close');
    });
  }

  void _toggleBookMark(ChapterModel chapter) {
    toggleBookMark(
      sourcePath: currentNovelNotifier.value!.path,
      title: 'Untitled',
      chapter: chapter.title,
      onSuccess: () {
        setState(() {});
        //update
        getBookMarkList(
          sourcePath: currentNovelNotifier.value!.path,
          onSuccess: (chapterBookList) {
            chapterBookMarkListNotifier.value = chapterBookList;
          },
          onError: (err) {
            debugPrint(err);
          },
        );
      },
      onError: (err) {
        debugPrint(err);
      },
    );
  }

  void _toggleFullScreen() async {
    setState(() {
      isFullScreen = !isFullScreen;
    });
    toggleFullScreenPlatform(isFullScreen);
  }

  Future<bool> _showConfirmReadedDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('အတည်ပြုခြင်း'),
            content: Text(
                'readed chapter "$currentChapterNumber" ကိုမှတ်သားထားချင်ပါသလား?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('မသိမ်းဘူး'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  final novel = currentNovelNotifier.value!;
                  novel.readed = currentChapterNumber;
                  //update data
                  updateNovelReaded(novel: novel);
                  //update ui
                  currentNovelNotifier.value = novel;
                },
                child: const Text('သိမ်းမယ်'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _onBackpress() async {
    bool res = true;
    try {
      int readed = currentNovelNotifier.value!.readed;
      if (currentChapterNumber > readed) {
        res = await _showConfirmReadedDialog();
      }
    } catch (e) {
      debugPrint('_onBackpress: ${e.toString()}');
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    bool isExistsBookmark = existsBookMark(
      sourcePath: currentNovelNotifier.value!.path,
      chapter: currentChapter.title,
    );
    return WillPopScope(
      onWillPop: () async {
        return await _onBackpress();
      },
      child: MyScaffold(
        appBar: isFullScreen
            ? null
            : AppBar(
                title: Text('Ch: $currentChapterNumber'),
                actions: [
                  //book mark
                  IconButton(
                    onPressed: () => _toggleBookMark(currentChapter),
                    color: isExistsBookmark ? dangerColor : activeColor,
                    icon: Icon(
                      isExistsBookmark
                          ? Icons.bookmark_remove
                          : Icons.bookmark_add,
                    ),
                  ),
                  //setting
                  IconButton(
                    onPressed: () {
                      showMenu();
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
        body: GestureDetector(
          onTap: _toggleFullScreen,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                //header
                _Header(
                  chapter: currentChapter,
                  prevClick: _prevChapter,
                  nextClick: _nextChapter,
                ),
                const Divider(),
                Text(
                  getChapterContent(
                      chapterPath:
                          '${currentNovelNotifier.value!.path}/$currentChapterNumber'),
                  style: TextStyle(
                    fontSize: readerConfig.fontSize,
                  ),
                ),

                //footer
                isShowBottomChapterNavBar
                    ? _Header(
                        chapter: currentChapter,
                        prevClick: _prevChapter,
                        nextClick: _nextChapter,
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  ChapterModel chapter;
  void Function() prevClick;
  void Function() nextClick;

  _Header({
    required this.chapter,
    required this.nextClick,
    required this.prevClick,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: prevClick,
            icon: const Icon(Icons.arrow_back_ios),
          ),
          Text('Chapter ${chapter.title}'),
          IconButton(
            onPressed: nextClick,
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }
}
