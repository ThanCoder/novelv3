import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/factorys/file_scanner_factory.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:t_widgets/t_widgets.dart';

import '../novel_dir_app.dart';

typedef IsolatePerparingSearchListReturn = (
  List<Novel> novelList,
  List<String> author,
  List<String> translator,
  List<String> mc,
  List<String> tags,
);

class NovelSearchScreen extends StatefulWidget {
  Duration searchDelay;
  NovelSearchScreen({
    super.key,
    this.searchDelay = const Duration(milliseconds: 1500),
  });

  @override
  State<NovelSearchScreen> createState() => _NovelSearchScreenState();
}

class _NovelSearchScreenState extends State<NovelSearchScreen> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => init());
    init();
  }

  List<Novel> list = [];
  List<String> authorList = [];
  List<String> translatorList = [];
  List<String> mcList = [];
  List<String> tagsList = [];
  List<Novel> resultList = [];
  bool isShowSearchList = false;
  Timer? _searchDelayTimer;
  bool isLoading = false;
  bool isSearching = false;

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });

      final (novelList, author, translator, mc, tags) =
          await getPreparingSearchList();

      list = novelList;
      authorList = author;
      translatorList = translator;
      mcList = mc;
      tagsList = tags;
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchDelayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            TSearchField(
              hintText: 'Search...',
              onChanged: _onSearchChange,
              autofocus: false,
              onCleared: () {
                resultList.clear();
                isShowSearchList = false;
                setState(() {});
              },
            ),
            isSearching ? LinearProgressIndicator() : SizedBox.shrink(),
          ],
        ),
      ),
      body: _getSwitchWidget(),
    );
  }

  // event
  void _onSearchChange(String text) {
    if (_searchDelayTimer?.isActive ?? false) {
      _searchDelayTimer?.cancel();
    }
    if (text.isEmpty) {
      setState(() {
        isSearching = false;
      });
      return;
    }
    if (!isSearching) {
      setState(() {
        isSearching = true;
      });
    }

    _searchDelayTimer = Timer(widget.searchDelay, () => _onSearch(text));
  }

  void _onSearch(String text) {
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
    setState(() {
      isShowSearchList = true;
      isSearching = false;
    });
  }
  //

  Widget _getSwitchWidget() {
    if (isLoading) {
      return Center(child: TLoaderRandom());
    }
    if (isShowSearchList && resultList.isEmpty) {
      return Center(child: Text('ရှာမတွေ့ပါ....'));
    }
    if (isShowSearchList && resultList.isNotEmpty) {
      return ListView.builder(
        itemCount: resultList.length,
        itemBuilder: (context, index) => NovelListItem(
          novel: resultList[index],
          onClicked: (novel) {
            goNovelContentScreen(context, novel);
          },
        ),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _getAuthorList()),
        SliverToBoxAdapter(child: _getTranslatorList()),
        SliverToBoxAdapter(child: _getTagsList()),
        SliverToBoxAdapter(child: _getMCList()),
      ],
    );
  }

  Widget _getAuthorList() {
    return _getWrap(
      'Author',
      authorList,
      onClicked: (text) {
        final res = list.where((e) => e.getAuthor == text).toList();
        goNovelSeeAllScreen(context, text, res);
      },
    );
  }

  Widget _getTranslatorList() {
    return _getWrap(
      'Translator',
      translatorList,
      onClicked: (text) {
        final res = list.where((e) => e.getTranslator == text).toList();
        goNovelSeeAllScreen(context, text, res);
      },
    );
  }

  Widget _getMCList() {
    return _getWrap(
      'MC',
      mcList,
      onClicked: (text) {
        final res = list.where((e) => e.getMC == text).toList();
        goNovelSeeAllScreen(context, text, res);
      },
    );
  }

  Widget _getTagsList() {
    return _getWrap(
      'Tags',
      tagsList,
      onClicked: (text) {
        final res = list.where((e) => e.getTagContent.contains(text)).toList();
        goNovelSeeAllScreen(context, text, res);
      },
    );
  }

  Widget _getWrap(
    String title,
    List<String> list, {
    void Function(String text)? onClicked,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(title),
            TTagsWrapView(values: list, onClicked: onClicked),
          ],
        ),
      ),
    );
  }

  //static
  static Future<IsolatePerparingSearchListReturn>
  getPreparingSearchList() async {
    final rootPath = FolderFileServices.getSourcePath();

    //final (novelList, author, translator, mc, tags) =
    return await Isolate.run<IsolatePerparingSearchListReturn>(() async {
      final list = await FileScannerFactory.getScanner<Novel>().getList(
        rootPath,
      );
      final author = list.map((e) => e.getAuthor).toSet().toList();
      final translator = list.map((e) => e.getTranslator).toSet().toList();
      final mc = list.map((e) => e.getMC).toSet().toList();
      final tags = list.expand((e) => e.getTags).toSet().toList();
      final result = (list, author, translator, mc, tags);
      return result;
    });
  }
}
