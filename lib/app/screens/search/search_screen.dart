import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/screens/search/search_home.dart';
import 'package:novel_v3/app/screens/search/search_result_list.dart';
import 'package:novel_v3/app/widgets/search_field.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:t_widgets/t_widgets.dart';

import '../../models/index.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  bool isShowResult = false;
  bool isLoading = false;
  List<NovelModel> resultList = [];

  Future<void> _searchText(String query) async {
    setState(() {
      isLoading = true;
      isShowResult = false;
    });
    // await Future.delayed(const Duration(seconds: 2));

    List<NovelModel> list = ref.watch(novelNotifierProvider).list;
    // filter
    final res = list.where((nv) {
      if (nv.title.toLowerCase().contains(query.toLowerCase())) {
        return true;
      }
      //mc
      if (nv.mc.toLowerCase().contains(query.toLowerCase())) {
        return true;
      }
      //author
      if (nv.author.toLowerCase().contains(query.toLowerCase())) {
        return true;
      }
      if (nv.getContent.contains(query)) {
        return true;
      }
      return false;
    }).toList();
    // sort
    res.sort((a, b) => a.title.compareTo(b.title));

    resultList = res;
    if (!mounted) return;
    setState(() {
      isShowResult = true;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<NovelModel> list = ref.watch(novelNotifierProvider).list;
    return Scaffold(
      appBar: AppBar(
        title: SearchField(
          onSubmitted: _searchText,
          onCleared: () {
            setState(() {
              isShowResult = false;
              isLoading = false;
            });
          },
        ),
      ),
      body: isLoading
          ? TLoader()
          : isShowResult
              ? SearchResultList(list: resultList)
              : SearchHome(list: list),
    );
  }
}
