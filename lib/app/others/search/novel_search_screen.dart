import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/factorys/file_scanner_factory.dart';
import 'package:novel_v3/app/ui/routes_helper.dart';
import 'package:t_widgets/t_widgets.dart';

import '../../ui/novel_dir_app.dart';

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
          await _getPreparingSearchList();

      // sort
      author.sort((a, b) => a.compareTo(b));
      translator.sort((a, b) => a.compareTo(b));
      mc.sort((a, b) => a.compareTo(b));
      tags.sort((a, b) => a.compareTo(b));

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

  void _onSearch(String text) async {
    // list ကို sendable အဖြစ် serialize
    // final listMap = list.map((e) => e.toMap()).toList();
    final upper = text.toUpperCase();

    resultList = list.where((e) {
      if (e.title.toUpperCase().contains(upper)) {
        return true;
      }
      if (e.meta.mc.toUpperCase().contains(upper)) {
        return true;
      }
      if (e.meta.author.toUpperCase().contains(upper)) {
        return true;
      }
      if (e.meta.translator != null &&
          e.meta.translator!.toUpperCase().contains(upper)) {
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
        SliverToBoxAdapter(child: authorList.isEmpty ? null : _getAuthorList()),
        SliverToBoxAdapter(
          child: translatorList.isEmpty ? null : _getTranslatorList(),
        ),
        SliverToBoxAdapter(child: tagsList.isEmpty ? null : _getTagsList()),
        SliverToBoxAdapter(child: mcList.isEmpty ? null : _getMCList()),
      ],
    );
  }

  Widget _getAuthorList() {
    return _getWrap(
      'Author',
      authorList,
      onClicked: (text) {
        final res = list.where((e) => e.meta.author == text).toList();
        goNovelSeeAllScreen(context, text, res);
      },
    );
  }

  Widget _getTranslatorList() {
    return _getWrap(
      'Translator',
      translatorList,
      onClicked: (text) {
        final res = list.where((e) => e.meta.translator == text).toList();
        goNovelSeeAllScreen(context, text, res);
      },
    );
  }

  Widget _getMCList() {
    return _getWrap(
      'MC',
      mcList,
      onClicked: (text) {
        final res = list.where((e) => e.meta.mc == text).toList();
        goNovelSeeAllScreen(context, text, res);
      },
    );
  }

  Widget _getTagsList() {
    return _getWrap(
      'Tags',
      tagsList,
      onClicked: (text) {
        final res = list.where((e) => e.meta.desc.contains(text)).toList();
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
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TTagsWrapView(values: list, onClicked: onClicked),
          ],
        ),
      ),
    );
  }
}

///
/// ### Return (novelList, author, translator, mc, tags)
///
Future<IsolatePerparingSearchListReturn> _getPreparingSearchList() async {
  final rootPath = FolderFileServices.getSourcePath();

  //final (novelList, author, translator, mc, tags) =
  return await Isolate.run<IsolatePerparingSearchListReturn>(() async {
    final list = await FileScannerFactory.getScanner<Novel>().getList(rootPath);
    final author = list.map((e) => e.meta.author).toSet().toList();
    final translator = list
        .where((e) => e.meta.translator != null)
        .map((e) => e.meta.translator ?? '')
        .toSet()
        .toList();
    final mc = list.map((e) => e.meta.mc).toSet().toList();
    final tags = list
        .expand((e) => e.meta.tags)
        .map((e) => e.trim())
        .toSet()
        .toList();
    final result = (list, author, translator, mc, tags);
    return result;
  });
}
