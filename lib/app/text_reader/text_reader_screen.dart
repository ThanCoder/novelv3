import 'dart:io';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/core/index.dart';
import 'package:novel_v3/app/dialogs/index.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:provider/provider.dart';
import 'package:than_pkg/than_pkg.dart';

import '../widgets/core/index.dart';
import 'text_reader_config_model.dart';
import 'text_reader_setting_dialog.dart';

class TextReaderScreen extends StatefulWidget {
  ChapterModel data;
  TextReaderConfigModel config;
  bool? bookmarkValue;
  Future<bool> Function(ChapterModel data, bool bookmarkValue)?
      onBookmarkChanged;
  void Function(TextReaderConfigModel config)? onConfigChanged;
  TextReaderScreen({
    super.key,
    required this.data,
    required this.config,
    this.bookmarkValue,
    this.onBookmarkChanged,
    this.onConfigChanged,
  });

  @override
  State<TextReaderScreen> createState() => _TextReaderScreenState();
}

class _TextReaderScreenState extends State<TextReaderScreen> {
  final ScrollController _controller = ScrollController();

  List<ChapterModel> list = [];
  bool isDataLoading = false;
  late TextReaderConfigModel config;
  late ChapterModel currentData;
  bool isGetTopData = true;
  bool? bookmarkValue;
  bool isFullScreen = false;
  bool isCanGoBack = true;
  double maxScroll = 0;
  int readedChapter = 1;
  bool isShowPrevChapterConfirmBox = false;

  @override
  void initState() {
    _controller.addListener(_onScroll);
    config = widget.config;
    currentData = widget.data;
    bookmarkValue = widget.bookmarkValue;
    super.initState();
    init();
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    if (Platform.isAndroid) {
      ThanPkg.android.app.toggleKeepScreenOn(isKeep: false);
    }
    super.dispose();
  }

  void init() async {
    list.add(widget.data);
    setState(() {});
    initConfig();
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    readedChapter = novel.getReaded;
    _checkReadeConfirm();
  }

  void initConfig() {
    if (Platform.isAndroid) {
      ThanPkg.android.app.toggleKeepScreenOn(isKeep: config.isKeepScreen);
    }
  }

  void _checkReadeConfirm() {
    if (currentData.number > readedChapter) {
      isCanGoBack = false;
    } else {
      isCanGoBack = true;
    }
    setState(() {});
  }

  void _onScroll() {
    final max = _controller.position.maxScrollExtent;
    final pos = _controller.position.pixels;
    if (isGetTopData && pos.toInt() == 0) {
      if (!isDataLoading) {
        _loadTopItem();
      }
    }
    if (maxScroll != max && pos == max) {
      // maxScroll = max;
      if (!isDataLoading) {
        _loadDownItem();
      }
    }
  }

  void _loadTopItem() {
    isDataLoading = true;
    if (currentData.isExistsPrev()) {
      // currentData = currentData.getPrev();
      // list.insert(0, currentData);
      isShowPrevChapterConfirmBox = true;
    }
    // else {
    //   showMessage(context, '`${currentData.number + 1}` Chapter မရှိပါ ');
    // }
    isDataLoading = false;
    _checkReadeConfirm();
    setState(() {});
  }

  void _loadDownItem() {
    if (currentData.isExistsNext()) {
      isDataLoading = true;
      currentData = currentData.getNext();
      list.add(currentData);
      isDataLoading = false;
      setState(() {});
      _checkReadeConfirm();
    } else {
      // showMessage(context, '`${currentData.number + 1}` Chapter မရှိပါ ');
    }
  }

  void _toggleBookMark() async {
    if (widget.onBookmarkChanged != null) {
      bookmarkValue =
          await widget.onBookmarkChanged!(currentData, bookmarkValue!);
    }
    if (!mounted) return;
    setState(() {});
  }

  void _showSetting() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TextReaderSettingDialog(
        config: config,
        onApply: (changedConfig) {
          config = changedConfig;
          if (widget.onConfigChanged != null) {
            widget.onConfigChanged!(changedConfig);
          }
          setState(() {});
          initConfig();
        },
      ),
    );
  }

  void _toggleFullScreen() {
    isFullScreen = !isFullScreen;
    ThanPkg.platform.toggleFullScreen(isFullScreen: isFullScreen);
    setState(() {});
  }

  void _goBackConfirm() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        cancelText: 'မသိမ်းဘူး',
        submitText: 'သိမ်းမယ်',
        contentText:
            '`${currentData.number}` > Readed:`$readedChapter` ထက်ကြီးနေပါတယ်။\n`${currentData.number}` -> Readed ထဲသိမ်းဆည်းချင်ပါသလား?။',
        onCancel: () {
          setState(() {
            isCanGoBack = true;
          });
          Navigator.pop(context);
        },
        onSubmit: () {
          try {
            readedChapter = currentData.number;
            final novel = context.read<NovelProvider>().getCurrent;
            if (novel == null) return;
            novel.setReaded(readedChapter);
            context.read<NovelProvider>().refreshCurrent();
          } catch (e) {
            showDialogMessage(context, e.toString());
          }
          setState(() {
            isCanGoBack = true;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _showPreChapterWidget() {
    if (!isShowPrevChapterConfirmBox) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Go Chapter: ${currentData.number - 1}'),
            IconButton(
              onPressed: () {
                currentData = currentData.getPrev();
                list.insert(0, currentData);
                isShowPrevChapterConfirmBox = false;
                setState(() {});
              },
              iconSize: 40,
              icon: const Icon(Icons.upload),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final novel = context.read<NovelProvider>().getCurrent;
    return PopScope(
      canPop: isCanGoBack,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goBackConfirm();
          return;
        }
        if (novel == null) return;
        novel.setRecenTextReader(currentData);
      },
      child: MyScaffold(
        contentPadding: 0,
        body: GestureDetector(
          onLongPress: _showSetting,
          onSecondaryTap: _showSetting,
          onDoubleTap: _toggleFullScreen,
          child: CustomScrollView(
            controller: _controller,
            slivers: [
              SliverAppBar(
                title: Text('${currentData.number}: ${currentData.title}'),
                snap: !isFullScreen,
                floating: !isFullScreen,
                actions: [
                  bookmarkValue == null
                      ? const SizedBox.shrink()
                      : IconButton(
                          color: bookmarkValue! ? Colors.red : Colors.teal,
                          onPressed: _toggleBookMark,
                          icon: Icon(bookmarkValue!
                              ? Icons.bookmark_remove_rounded
                              : Icons.bookmark_add_rounded),
                        ),
                ],
              ),
              SliverToBoxAdapter(child: _showPreChapterWidget()),
              // list
              SliverList.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final ch = list[index];
                  return Padding(
                    padding: EdgeInsets.all(config.padding),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        const Divider(),
                        Column(
                          children: [
                            Text(
                              'Chapter: ${ch.number}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Text(
                          ch.getContent(),
                          style: TextStyle(
                            fontSize: config.fontSize,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
