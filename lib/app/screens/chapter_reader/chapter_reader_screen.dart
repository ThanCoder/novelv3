import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:novel_v3/app/novel_dir_app.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ChapterReaderScreen extends StatefulWidget {
  Chapter chapter;
  void Function(Chapter lastChapter)? onReaderClosed;
  ChapterReaderScreen({super.key, required this.chapter, this.onReaderClosed});

  @override
  State<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  List<Chapter> list = [];
  final controller = ScrollController();
  double lastScrollPos = 0;
  bool isLoading = false;
  bool isShowGetPrevChapter = true;
  Chapter? topChapter;
  bool isFullScreen = false;

  @override
  void initState() {
    list.add(widget.chapter);
    controller.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onReaderClosed?.call(list.last),
        );
      },
      child: TScaffold(
        body: GestureDetector(
          onDoubleTap: () => _toggleFullScreen(),

          child: CustomScrollView(
            controller: controller,
            slivers: [
              isFullScreen
                  ? SliverToBoxAdapter()
                  : SliverAppBar(
                      title: Text('Chapter Reader'),
                      snap: true,
                      floating: true,
                      backgroundColor: Setting.getAppConfig.isDarkTheme
                          ? Colors.black.withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: 0.8),
                    ),
              // top
              SliverToBoxAdapter(child: _getPrevChapterWidget()),
              // list
              SliverList.separated(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      item.getContents,
                      style: TextStyle(fontSize: 19),
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
          ),
        ),
      ),
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Icon(Icons.keyboard_arrow_up_rounded, size: 30),
                Text('Chapter: ${topChapter!.number}'),
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

  // save readed config dialog
  // bool get _isCanGoback {
  //   final novel = context.read<NovelProvider>().getCurrent;
  //   if (novel == null) return true;
  //   final readed = novel.getReadedNumber;
  //   //ကြီးနေတယ်ဆိုရင်
  //   // current > readed
  //   if (list.last.number > readed) return false;
  //   return true;
  // }

  // void _showReadedConfirmDialog() {
  //   try {
  //     final novel = context.read<NovelProvider>().getCurrent;
  //     if (novel == null) return;
  //     final lastChapter = list.last;
  //     final readed = novel.getReadedNumber;
  //     if (lastChapter.number <= readed) return;
  //     showTConfirmDialog(
  //       context,
  //       barrierDismissible: false,
  //       title: 'Readed ကိုသိမ်းဆည်းချင်ပါသလား?',
  //       contentText:
  //           'သိမ်းဆည်းထားသော Chapter:`$readed`\nဖတ်ပြီးသွားတဲ့ Chapter:`${lastChapter.number}`',
  //       submitText: 'သိမ်းမယ်',
  //       cancelText: 'မသိမ်းဘူး',
  //       onCancel: () async {
  //         if (!mounted) return;
  //         setState(() {});
  //         closeContext(context);
  //       },
  //       onSubmit: () async {
  //         novel.setReaded(lastChapter.number.toString());
  //         if (!mounted) return;
  //         context.read<NovelProvider>().refreshNotifier();
  //         setState(() {});
  //         closeContext(context);
  //       },
  //     );
  //   } catch (e) {
  //     NovelDirApp.showDebugLog(
  //       e.toString(),
  //       tag: 'ChapterReaderScreen:_showReadedConfirmDialog',
  //     );
  //   }
  // }
}
