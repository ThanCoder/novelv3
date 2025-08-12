import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:novel_v3/app/types/index.dart';
import 'package:t_widgets/t_widgets.dart';

class ChapterReaderScreen extends StatefulWidget {
  Chapter chapter;
  ChapterReaderScreen({super.key, required this.chapter});

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

  @override
  void initState() {
    list.add(widget.chapter);
    controller.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TScaffold(
      body: CustomScrollView(
        controller: controller,
        slivers: [
          SliverAppBar(
            title: Text('Chapter Reader'),
            snap: true,
            floating: true,
            backgroundColor: Colors.black.withValues(alpha: 0.8),
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
                child: Text(item.getContents, style: TextStyle(fontSize: 19)),
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
}
