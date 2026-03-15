import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/main/styles/sliver_list_style.dart';
import 'package:novel_v3/core/extensions/novel_filters_extension.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/old_app/ui/components/wrap_more_less.dart';
import 'package:t_widgets/t_widgets.dart';

class SearchScreen extends StatefulWidget {
  final List<Novel> list;
  final void Function(Novel novel) onClicked;
  final void Function(String title, List<Novel> list)? onSearchResultPage;
  const SearchScreen({
    super.key,
    required this.list,
    required this.onClicked,
    this.onSearchResultPage,
  });

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
          widget.list.getAllAuthors.toList(),
          onClicked: (name) {
            final list = widget.list.filterAuthor(name);
            _goSearchResultPage(name, list);
          },
        ),
      ),
      SliverToBoxAdapter(
        child: _getWrapWiget(
          'ဘာသာပြန်',
          widget.list.getAllTranslators.toList(),
          onClicked: (name) {
            final list = widget.list.filterTranslator(name);
            _goSearchResultPage(name, list);
          },
        ),
      ),
      SliverToBoxAdapter(
        child: _getWrapWiget(
          'အထိက ဇောတ်ကောင်',
          widget.list.getAllMC.toList(),
          onClicked: (name) {
            final list = widget.list.filterMC(name);
            _goSearchResultPage(name, list);
          },
        ),
      ),
      SliverToBoxAdapter(
        child: _getWrapWiget(
          'Tags',
          widget.list.getAllTags.toList(),
          onClicked: (name) {
            final list = widget.list.filterTag(name);
            _goSearchResultPage(name, list);
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
    return SliverListStyle(list: resultList, onClicked: widget.onClicked);
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

    resultList = widget.list.where((e) {
      if (e.meta.title.toUpperCase().contains(upper)) {
        return true;
      }
      if (e.meta.englishTitle.toUpperCase().contains(upper)) {
        return true;
      }
      if (e.meta.originalTitle.toUpperCase().contains(upper)) {
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
    resultList.sort((a, b) {
      if (a.meta.title.toUpperCase().indexOf(upper) >
          b.meta.title.toUpperCase().indexOf(upper)) {
        return 1;
      }
      if (a.meta.title.toUpperCase().indexOf(upper) <
          b.meta.title.toUpperCase().indexOf(upper)) {
        return -1;
      }
      return 0;
    });
    setState(() {
      isShowResult = true;
      isSearching = false;
    });
  }

  void _goSearchResultPage(String title, List<Novel> list) {
    widget.onSearchResultPage?.call(title, list);
  }
}
