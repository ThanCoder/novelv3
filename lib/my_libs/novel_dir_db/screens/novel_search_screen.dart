import 'package:flutter/material.dart';
import 'package:novel_v3/my_libs/novel_v3_uploader_v1.3.0/novel_v3_uploader.dart';
import '../novel_dir_db.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/widgets/t_search_field.dart';

class NovelSearchScreen extends StatefulWidget {
  const NovelSearchScreen({super.key});

  @override
  State<NovelSearchScreen> createState() => _NovelSearchScreenState();
}

class _NovelSearchScreenState extends State<NovelSearchScreen> {
  List<Novel> list = [];
  List<Novel> resultList = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  void init() async {
    list = context.read<NovelProvider>().getList;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TSearchField(
          hintText: 'Search...',
          onChanged: _onSearch,
          onCleared: () {
            resultList.clear();
            setState(() {});
          },
        ),
      ),
      body: _getSwitchWidget(),
    );
  }

  void _onSearch(String text) {
    if (text.isEmpty) {
      resultList.clear();
      setState(() {});
      return;
    }
    resultList = list.where((e) {
      if (e.title.toUpperCase().contains(text.toUpperCase())) {
        return true;
      }
      if (e.getMC.toUpperCase().contains(text.toUpperCase())) {
        return true;
      }
      if (e.getAuthor.toUpperCase().contains(text.toUpperCase())) {
        return true;
      }
      if (e.getTranslator.toUpperCase().contains(text.toUpperCase())) {
        return true;
      }
      return false;
    }).toList();
    // sort
    resultList.sort((a, b) => a.title.compareTo(b.title));
    setState(() {});
  }

  Widget _getSwitchWidget() {
    if (resultList.isNotEmpty) {
      return ListView.builder(
        itemCount: resultList.length,
        itemBuilder: (context, index) => NovelListItem(
          novel: resultList[index],
          onClicked: (novel) {
            goContentScreen(context, novel);
          },
        ),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _getAuthorList(list),
        ),
        SliverToBoxAdapter(
          child: _getTranslatorList(list),
        ),
        SliverToBoxAdapter(
          child: _getTagsList(list),
        ),
        SliverToBoxAdapter(
          child: _getMCList(list),
        ),
      ],
    );
  }

  Widget _getAuthorList(List<Novel> list) {
    final res = list.map((e) => e.getAuthor).toSet().toList();
    return _getWrap(
      'Author',
      res,
      onClicked: (text) {
        final res = list.where((e) => e.getAuthor == text).toList();
        goNovelSeeAllScreen(context, text, res);
      },
    );
  }

  Widget _getTranslatorList(List<Novel> list) {
    final res = list.map((e) => e.getTranslator).toSet().toList();
    return _getWrap(
      'Translator',
      res,
      onClicked: (text) {
        final res = list.where((e) => e.getTranslator == text).toList();
        goNovelSeeAllScreen(context, text, res);
      },
    );
  }

  Widget _getMCList(List<Novel> list) {
    final res = list.map((e) => e.getMC).toSet().toList();
    return _getWrap(
      'MC',
      res,
      onClicked: (text) {
        final res = list.where((e) => e.getMC == text).toList();
        goNovelSeeAllScreen(context, text, res);
      },
    );
  }

  Widget _getTagsList(List<Novel> list) {
    final res = list.expand((e) => e.getTags).toSet().toList();
    return _getWrap(
      'Tags',
      res,
      onClicked: (text) {
        final res = list.where((e) => e.getTagContent.contains(text)).toList();
        goNovelSeeAllScreen(context, text, res);
      },
    );
  }

  Widget _getWrap(String title, List<String> list,
      {void Function(String text)? onClicked}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(title),
            TagWrapView(
              list: list,
              onClicked: onClicked,
            ),
          ],
        ),
      ),
    );
  }
}
