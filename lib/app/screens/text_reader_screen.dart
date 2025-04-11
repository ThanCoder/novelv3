import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/widgets/index.dart';

class TextReaderScreen extends StatefulWidget {
  ChapterModel chapter;
  TextReaderConfigModel config;
  TextReaderScreen({
    super.key,
    required this.chapter,
    required this.config,
  });

  @override
  State<TextReaderScreen> createState() => _TextReaderScreenState();
}

class _TextReaderScreenState extends State<TextReaderScreen> {
  final ScrollController _controller = ScrollController();
  @override
  void initState() {
    _controller.addListener(_onScroll);
    config = widget.config;
    currentChapter = widget.chapter;
    super.initState();
    init();
  }

  List<ChapterModel> list = [];
  bool isLoading = false;
  late TextReaderConfigModel config;
  late ChapterModel currentChapter;

  void init() async {
    list.add(widget.chapter);
    setState(() {});
  }

  double maxScroll = 0;

  void _onScroll() {
    if (_controller.position.pixels == 0) {
      if (isLoading) return;
      _loadTopItem();
    }
    if (maxScroll != _controller.position.maxScrollExtent &&
        _controller.position.pixels == _controller.position.maxScrollExtent) {
      maxScroll = _controller.position.maxScrollExtent;
      if (isLoading) return;
      _loadDownItem();
    }
  }

  void _loadTopItem() {
    isLoading = true;
    if (currentChapter.isExistPrev()) {
      currentChapter = currentChapter.getPrev();
      list.insert(0, currentChapter);
    } else {
      showMessage(context, '`${currentChapter.number + 1}` Chapter မရှိပါ ');
    }
    isLoading = false;
    setState(() {});
  }

  void _loadDownItem() {
    isLoading = true;
    if (currentChapter.isExistNext()) {
      currentChapter = currentChapter.getNext();
      list.add(currentChapter);
    } else {
      showMessage(context, '`${currentChapter.number + 1}` Chapter မရှိပါ ');
    }
    isLoading = false;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 0,
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverAppBar(
            title: Text('${currentChapter.number}'),
            snap: true,
            floating: true,
          ),
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
                          Text('Chapter: ${ch.number}'),
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
              }),
        ],
      ),
    );
  }
}
