import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/components/wrap_more_less.dart';
import 'package:novel_v3/app/ui/components/novel_list_item.dart';
import 'package:novel_v3/app/ui/content/content_screen.dart';
import 'package:novel_v3/app/ui/search/search_result_screen.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isShowResult = false;
  bool isSearching = false;
  List<Novel> resultList = [];
  Timer? _timer;

  @override
  void dispose() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    super.dispose();
  }

  NovelProvider get getWProvider => context.watch<NovelProvider>();
  NovelProvider get getRProvider => context.read<NovelProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: CustomScrollView(
        slivers: [
          _getSearchWidget(),
          ..._getLandingList(),
          isShowResult ? _getResultWidget() : SliverToBoxAdapter(),
        ],
      ),
    );
  }

  Widget _getSearchWidget() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      snap: true,
      floating: true,
      pinned: false,
      flexibleSpace: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TSearchField(
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchChanged,
              autofocus: false,
              onCleared: () {
                setState(() {
                  isShowResult = false;
                  isSearching = false;
                });
              },
            ),
            isSearching ? LinearProgressIndicator() : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  List<Widget> _getLandingList() {
    if (isShowResult) return [];
    return [
      SliverToBoxAdapter(
        child: _getWrapWiget(
          'စာရေးဆရာ',
          getWProvider.getAllAuthors,
          onClicked: (name) {
            final list = getRProvider.searchAuthor(name);
            _goSearchResultPage('စာရေးဆရာ', list);
          },
        ),
      ),
      SliverToBoxAdapter(
        child: _getWrapWiget(
          'ဘာသာပြန်',
          getWProvider.getAllTranslator,
          onClicked: (name) {
            final list = getRProvider.searchTranslator(name);
            _goSearchResultPage('ဘာသာပြန်', list);
          },
        ),
      ),
      SliverToBoxAdapter(
        child: _getWrapWiget(
          'အထိက ဇောတ်ကောင်',
          getWProvider.getAllMC,
          onClicked: (name) {
            final list = getRProvider.searchMC(name);
            _goSearchResultPage('အထိက ဇောတ်ကောင်', list);
          },
        ),
      ),
      SliverToBoxAdapter(
        child: _getWrapWiget(
          'Tags',
          getWProvider.getAllTags,
          onClicked: (name) {
            final list = getRProvider.searchTag(name);
            _goSearchResultPage('Tags', list);
          },
        ),
      ),
    ];
  }

  Widget _getResultWidget() {
    if (resultList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'ရှာမတွေ့ပါ...',
            style: TextTheme.of(context).headlineSmall,
          ),
        ),
      );
    }
    return SliverList.builder(
      itemCount: resultList.length,
      itemBuilder: (context, index) => NovelListItem(
        novel: resultList[index],
        onClicked: _goNovelContentPage,
      ),
    );
  }

  Widget _getWrapWiget(
    String title,
    List<String> names, {
    void Function(String name)? onClicked,
  }) {
    return WrapMoreLess(title: title, names: names, onClicked: onClicked);
  }

  void _onSearchChanged(String text) {
    if (text.isEmpty) {
      setState(() {
        isShowResult = false;
        isSearching = false;
      });
      return;
    }

    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    setState(() {
      isSearching = true;
    });
    _timer = Timer(Duration(milliseconds: 1200), () => _onSearch(text));
  }

  void _onSearch(String text) {
    final upper = text.toUpperCase();

    resultList = getRProvider.list.where((e) {
      if (e.title.toUpperCase().contains(upper)) {
        return true;
      }
      if (e.meta.mc.toUpperCase().contains(upper)) {
        return true;
      }
      if (e.meta.author.toUpperCase().contains(upper)) {
        return true;
      }
      if (e.meta.translator.isNotEmpty &&
          e.meta.translator.toUpperCase().contains(upper)) {
        return true;
      }
      return false;
    }).toList();
    resultList.sort((a, b) => a.title.compareTo(b.title));
    setState(() {
      isShowResult = true;
      isSearching = false;
    });
  }

  void _goNovelContentPage(Novel novel) async {
    await context.read<NovelProvider>().setCurrentNovel(novel);
    if (!mounted) return;
    goRoute(context, builder: (context) => ContentScreen());
  }

  void _goSearchResultPage(String title, List<Novel> list) {
    goRoute(
      context,
      builder: (context) => SearchResultScreen(title: title, list: list),
    );
  }
}
