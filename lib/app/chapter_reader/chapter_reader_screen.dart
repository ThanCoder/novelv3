import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:novel_v3/app/bookmark/chapter_bookmark_action.dart';
import 'package:novel_v3/app/chapter_reader/chapter_reader_config.dart';
import 'package:novel_v3/app/novel_dir_app.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import 'reader_config_dialog.dart';

typedef OnChapterReaderCloseCallback = void Function(Chapter lastChapter);

class ChapterReaderScreen extends StatefulWidget {
  final Chapter chapter;
  final ChapterReaderConfig config;
  final OnUpdateConfigCallback? onUpdateConfig;
  final OnChapterReaderCloseCallback? onReaderClosed;
  const ChapterReaderScreen({
    super.key,
    required this.chapter,
    this.onReaderClosed,
    required this.config,
    this.onUpdateConfig,
  });

  @override
  State<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  late ChapterReaderConfig config;
  List<Chapter> list = [];
  final controller = ScrollController();
  double lastScrollPos = 0;
  bool isLoading = false;
  bool isShowGetPrevChapter = true;
  Chapter? topChapter;
  bool isFullScreen = false;

  @override
  void initState() {
    config = widget.config;
    list.add(widget.chapter);
    controller.addListener(_onScroll);
    super.initState();
    initConfig();
  }

  void initConfig() async {
    try {
      ThanPkg.platform.toggleKeepScreen(isKeep: config.isKeepScreening);
      setState(() {});
    } catch (e) {
      debugPrint('[ChapterReaderScreen:initConfig]: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    ThanPkg.platform.toggleKeepScreen(isKeep: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onReaderClosed?.call(list.last);
          widget.onUpdateConfig?.call(config);
        });
      },
      child: TScaffold(
        body: GestureDetector(
          onDoubleTap: () => _toggleFullScreen(),
          onLongPress: _showConfigDialog,
          onSecondaryTap: _showConfigDialog,
          child: Container(
            color: config.theme.bgColor,
            child: _getListWidget(),
          ),
        ),
      ),
    );
  }

  Widget _getListWidget() {
    return CustomScrollView(
      controller: controller,
      slivers: [
        isFullScreen
            ? SliverToBoxAdapter()
            : SliverAppBar(
                title: Text(
                  'Chapter Reader',
                  style: TextStyle(color: config.theme.fontColor),
                ),
                snap: true,
                floating: true,
                backgroundColor: config.theme.bgColor.withValues(alpha: 0.8),
                leading: IconButton(
                  color: config.theme.fontColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                ),
              ),
        // top
        SliverToBoxAdapter(child: _getPrevChapterWidget()),
        // list
        SliverList.separated(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: config.paddingY,
                horizontal: config.paddingX,
              ),
              child: Column(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ChapterBookmarkAction(
                    theme: config.theme,
                    chapter: item,
                    title: 'BookMark',
                  ),
                  Text(
                    item.getContents,
                    style: TextStyle(
                      fontSize: config.fontSize,
                      color: config.theme.fontColor,
                    ),
                  ),
                  // bookmark
                  ChapterBookmarkAction(
                    theme: config.theme,
                    chapter: item,
                    title: 'BookMark',
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) {
            final item = list[index];
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
          },
        ),
      ],
    );
  }

  Widget _getPrevChapterWidget() {
    if (!isShowGetPrevChapter || topChapter == null) {
      return SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () async {
        list.insert(0, topChapter!);
        isShowGetPrevChapter = false;
        setState(() {});
        await Future.delayed(Duration(seconds: 1));
        isLoading = false;
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          color: config.theme.bgColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 30,
                  color: Colors.teal,
                ),
                Text(
                  'Chapter: ${topChapter!.number}',
                  style: TextStyle(color: config.theme.fontColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onScroll() async {
    if (isLoading) return;

    final pos = controller.position;
    if (controller.position.userScrollDirection == ScrollDirection.reverse) {
      // scroll down
      if (lastScrollPos < pos.maxScrollExtent &&
          pos.maxScrollExtent == pos.pixels) {
        lastScrollPos = pos.maxScrollExtent;
        await _getNextChapter();
      }
      // print('max: ${pos.maxScrollExtent}');
      // print(pos.pixels);
    } else if (controller.position.userScrollDirection ==
        ScrollDirection.forward) {
      // scroll up
      if (pos.pixels == 0) {
        await _getPrevChapter();
      }
    }
  }

  Future<void> _getNextChapter() async {
    isLoading = true;
    final res = list.last.getNextChapter;
    if (res == null) {
      isLoading = false;
      return;
    }
    // ရှိနေရင်
    list.add(res);
    setState(() {});
    await Future.delayed(Duration(seconds: 2));
    isLoading = false;
  }

  Future<void> _getPrevChapter() async {
    isLoading = true;
    isShowGetPrevChapter = true;
    topChapter = list.first.getPrevChapter;
    setState(() {});
  }

  void _toggleFullScreen() {
    isFullScreen = !isFullScreen;
    ThanPkg.platform.toggleFullScreen(isFullScreen: isFullScreen);
    setState(() {});
  }

  // config dialog
  void _showConfigDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReaderConfigDialog(
        config: config,
        onUpdated: (updatedConfig) {
          config = updatedConfig;
          initConfig();
        },
      ),
    );
  }
}
