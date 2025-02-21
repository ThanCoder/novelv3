import 'dart:io';

import 'package:flutter/material.dart';

import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/dialogs/text_reader_config_dialog.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/models/text_reader_config_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';
import 'package:provider/provider.dart';

class ChapterTextReaderScreen extends StatefulWidget {
  const ChapterTextReaderScreen({super.key});

  @override
  State<ChapterTextReaderScreen> createState() =>
      _ChapterTextReaderScreenState();
}

class _ChapterTextReaderScreenState extends State<ChapterTextReaderScreen> {
  ScrollController scrollController = ScrollController();
  bool isFullScreen = false;
  late TextReaderConfigModel readerConfig;
  int currentChapterNumber = 0;
  late ChapterModel currentChapter;
  List<_ListItem> listItems = [];
  double lastScroll = 0;
  bool isCanGoBack = false;

  int getPositionFromList(String title) {
    return chapterListNotifier.value.indexWhere((c) => c.title == title);
  }

  @override
  void initState() {
    scrollController.addListener(_scroll);
    if (currentChapterNotifier.value != null) {
      currentChapterNumber = int.parse(currentChapterNotifier.value!.title);
      currentChapter = currentChapterNotifier.value!;
    }
    super.initState();
    readerConfig = getTextReaderConfig();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  void init() async {
    try {
      //keep screen
      _androidKeepScreen(readerConfig.isKeepScreen);

      final chapterProvider = context.read<ChapterProvider>();
      if (chapterProvider.getList.isEmpty) {
        chapterProvider.initList();
      }

      loadedChapter();
    } catch (e) {
      debugPrint('init: ${e.toString()}');
    }
  }

  void _androidKeepScreen(bool isKeep) async {
    toggleAndroidKeepScreen(isKeep);
  }

  void _scroll() {
    if (lastScroll != scrollController.position.maxScrollExtent &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      lastScroll = scrollController.position.maxScrollExtent;
      _nextChapter();
    }
  }

  void _nextChapter() async {
    try {
      setState(() {
        currentChapterNumber++;
      });
      if (currentChapterNumber == 0 ||
          currentChapterNumber > context.read<ChapterProvider>().lastChapter) {
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
          currentChapterNumber < context.read<ChapterProvider>().firstChapter) {
        showMessage(
            context, 'chapter "${currentChapterNumber.toString()}" မရှိပါ');
        currentChapterNumber++;
        return;
      }

      loadedChapter();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void loadedChapter() async {
    try {
      final path = '${currentNovelNotifier.value!.path}/$currentChapterNumber';
      final file = File(path);
      if (!file.existsSync()) {
        setState(() {
          isCanGoBack = true;
        });
        showMessage(
            context, 'chapter "${currentChapterNumber.toString()}" မရှိပါ');
        return;
      }
      //exists
      currentChapter = ChapterModel.fromPath(path);
      //set recent db
      setRecentDB('chapter_list_page_${currentNovelNotifier.value!.title}',
          currentChapter.title);

      listItems.add(
        _ListItem(
          title: currentChapter.title,
          pos: currentChapterNumber,
          content: getChapterContent(
              chapterPath:
                  '${currentNovelNotifier.value!.path}/$currentChapterNumber'),
        ),
      );
      //check can go back
      _checkCanGoback();
    } catch (e) {
      debugPrint('loadedChapter: ${e.toString()}');
    }
  }

  void _checkCanGoback() {
    int readed = currentNovelNotifier.value!.readed;
    if (currentChapterNumber > readed) {
      setState(() {
        isCanGoBack = false;
      });
    } else {
      setState(() {
        isCanGoBack = true;
      });
    }
  }

  void showSettingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TextReaderConfigDialog(
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

  Future<void> _onBackpress() async {
    try {
      int readed = currentNovelNotifier.value!.readed;
      if (currentChapterNumber > readed) {
        final res = await _showConfirmReadedDialog();
        setState(() {
          isCanGoBack = res;
        });
      } else {
        setState(() {
          isCanGoBack = true;
        });
      }
    } catch (e) {
      setState(() {
        isCanGoBack = true;
      });
      debugPrint('_onBackpress: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isExistsBookmark = existsBookMark(
      sourcePath: currentNovelNotifier.value!.path,
      chapter: currentChapter.title,
    );
    return PopScope(
      canPop: isCanGoBack,
      onPopInvokedWithResult: (didPop, result) {
        _onBackpress();
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
            child: Padding(
              padding: EdgeInsets.all(readerConfig.padding),
              child: ListView.separated(
                shrinkWrap: true,
                controller: scrollController,
                itemBuilder: (context, index) {
                  final item = listItems[index];
                  return Text(
                    item.content,
                    style: TextStyle(
                      fontSize: readerConfig.fontSize,
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                  height: 20,
                  child: Divider(),
                ),
                itemCount: listItems.length,
              ),
            )),
      ),
    );
  }

  @override
  void dispose() {
    toggleAndroidKeepScreen(false);
    super.dispose();
  }
}

class _ListItem {
  String title;
  int pos;
  String content;
  _ListItem({
    required this.title,
    required this.pos,
    required this.content,
  });
}
