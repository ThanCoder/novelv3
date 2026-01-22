import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/others/chapter_reader/chapter_bookmark_action.dart';
import 'package:novel_v3/app/others/chapter_reader/chapter_reader_config.dart';
import 'package:novel_v3/app/others/chapter_reader/chapter_reader_theme_listener.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import 'reader_config_dialog.dart';

typedef OnChapterReaderCloseCallback = void Function(Chapter lastChapter);
typedef OnGetChapterContentCallback =
    Future<String?> Function(BuildContext context, int chapterNumber);

class ChapterReaderScreen extends StatefulWidget {
  final Chapter chapter;
  final List<Chapter> allList;
  final ChapterReaderConfig config;
  final OnUpdateConfigCallback? onUpdateConfig;
  final OnChapterReaderCloseCallback? onReaderClosed;
  final OnGetChapterContentCallback getChapterContent;
  const ChapterReaderScreen({
    super.key,
    required this.chapter,
    required this.allList,
    required this.config,
    required this.getChapterContent,
    this.onReaderClosed,
    this.onUpdateConfig,
  });

  @override
  State<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  late ChapterReaderConfig config;
  List<Chapter> viewList = [];
  List<Chapter> allList = [];
  final controller = ScrollController();
  bool isLoading = false;
  bool isInitLoading = false;
  bool isFullScreen = false;
  bool canPop = true;

  @override
  void initState() {
    config = widget.config;
    viewList.add(widget.chapter);
    super.initState();
    initConfig();
    init();
  }

  @override
  void dispose() {
    controller.dispose();
    ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    ThanPkg.platform.toggleKeepScreen(isKeep: false);
    super.dispose();
  }

  void initConfig() async {
    try {
      ThanPkg.platform.toggleKeepScreen(isKeep: config.isKeepScreening);
      canPop = !config.isBackpressConfirm;
      setState(() {});
    } catch (e) {
      debugPrint('[ChapterReaderScreen:initConfig]: ${e.toString()}');
    }
  }

  void init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    try {
      setState(() {
        isInitLoading = true;
      });
      allList.addAll(widget.allList);
      allList.sort((a, b) => a.number.compareTo(b.number));
      if (!mounted) return;
      setState(() {
        isInitLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isInitLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!canPop) {
          _onBackConfirm();
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onReaderClosed?.call(viewList.last);
          widget.onUpdateConfig?.call(config);
        });
      },
      child: ChapterReaderThemeListener(
        theme: config.theme,
        builder: (context, themeData) => Theme(
          data: themeData,
          child: Scaffold(
            body: GestureDetector(
              onDoubleTap: () => _toggleFullScreen(),
              onLongPress: _showConfigDialog,
              onSecondaryTap: _showConfigDialog,
              child: _getView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getView() {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.arrowDown) {
          // 50 pixels စီ အောက်ကို ဆင်းခိုင်းခြင်း
          controller.animateTo(
            controller.offset + config.desktopArrowKeyScrollJumpToOffset,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
          );
          return KeyEventResult.handled; // ဒါမှ အောက်ဆုံးကို တန်းမခုန်တော့မှာပါ
        }
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.arrowUp) {
          controller.animateTo(
            controller.offset - config.desktopArrowKeyScrollJumpToOffset,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
          );
          return KeyEventResult.handled;
        }
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.space) {
          final currentChapterPos = allList.indexWhere(
            (e) => e.number == viewList.last.number,
          );
          if (currentChapterPos != -1) {
            final chapter = allList[currentChapterPos + 1];
            viewList.add(chapter);
            setState(() {});
          }
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: CustomScrollView(
        controller: controller,
        slivers: [
          _getAppbar(),
          // top
          _getPrevChapterWidget(),
          // list
          _getListWidget(),

          _getNextChapterWidget(),
        ],
      ),
    );
  }

  Widget _getAppbar() {
    if (isFullScreen) {
      return SliverToBoxAdapter();
    } else {
      return SliverAppBar(
        title: Text('Chapter Reader'),
        snap: true,
        floating: true,
        leading: IconButton(
          onPressed: () {
            if (config.isBackpressConfirm) {
              _onBackConfirm();
              return;
            }
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      );
    }
  }

  Widget _getListWidget() {
    if (isInitLoading) {
      return SliverFillRemaining(child: Center(child: TLoader.random()));
    }
    return SliverList.builder(
      itemCount: viewList.length,
      itemBuilder: (context, index) => _getListItem(index),
    );
  }

  Widget _getListItem(int index) {
    final item = viewList[index];
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: config.paddingY,
        horizontal: config.paddingX,
      ),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChapterBookmarkAction(
            theme: config.theme,
            chapter: item,
            title: 'BookMark',
          ),
          _getContentWidget(item, index),
          // bookmark
          ChapterBookmarkAction(
            theme: config.theme,
            chapter: item,
            title: 'BookMark',
          ),
          _getSeparator(index),
        ],
      ),
    );
  }

  Widget _getContentWidget(Chapter chapter, int index) {
    if (chapter.content != null) {
      return Text(
        'Chapter: ${chapter.number}\n\n${chapter.content}',
        style: TextStyle(fontSize: config.fontSize),
      );
    }
    return FutureBuilder(
      future: widget.getChapterContent(context, chapter.number),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: TLoader(color: Colors.blue));
        }
        final text = snapshot.data ?? '';
        viewList[index] = chapter.copyWith(content: text);
        return Text(
          'Chapter: ${chapter.number}\n\n$text',
          style: TextStyle(fontSize: config.fontSize),
        );
      },
    );
  }

  Widget _getSeparator(int index) {
    final item = viewList[index];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            'Chapter: ${item.number} End...',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _getPrevChapterWidget() {
    if (viewList.isEmpty) {
      return SliverToBoxAdapter();
    }
    final currentChapterPos = allList.indexWhere(
      (e) => e.number == viewList.first.number,
    );
    if (currentChapterPos == 0) {
      return SliverToBoxAdapter();
    }

    final chapter = allList[currentChapterPos - 1];

    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () async {
          viewList.insert(0, chapter);
          setState(() {});
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 30,
                    color: Colors.teal,
                  ),
                  Text('Read Chapter: ${chapter.number}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getNextChapterWidget() {
    if (viewList.isEmpty) {
      return SliverToBoxAdapter();
    }
    final currentChapterPos = allList.indexWhere(
      (e) => e.number == viewList.last.number,
    );
    if (currentChapterPos == -1 || currentChapterPos >= (allList.length - 1)) {
      return SliverToBoxAdapter(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Icon(Icons.not_interested_rounded, size: 30, color: Colors.red),
                Text(
                  'Chapter ထပ်မရှိတော့ပါ...',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final chapter = allList[currentChapterPos + 1];

    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () async {
          viewList.add(chapter);
          setState(() {});
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 30,
                    color: Colors.teal,
                  ),
                  Text('Read Chapter: ${chapter.number}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleFullScreen() {
    isFullScreen = !isFullScreen;
    ThanPkg.platform.toggleFullScreen(isFullScreen: isFullScreen);
    setState(() {});
  }

  // config dialog
  void _showConfigDialog() {
    showAdaptiveDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ReaderConfigDialog(
        config: config,
        onUpdated: (updatedConfig) {
          config = updatedConfig;
          initConfig();
        },
      ),
    );
  }

  // isBackconfig
  void _onBackConfirm() {
    try {
      showTConfirmDialog(
        context,
        contentText: 'အပြင်ထွက်ချင်တာ သေချာပြီလား?',
        submitText: 'ထွက်မယ်',
        cancelText: 'မထွက်ဘူး',
        onSubmit: () {
          canPop = true;
          setState(() {});
          Navigator.pop(context);
        },
      );
    } catch (e) {
      debugPrint('[_onBackConfirm]: ${e.toString()}');
    }
  }
}
