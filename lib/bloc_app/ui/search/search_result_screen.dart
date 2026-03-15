import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/main/styles/sliver_list_style.dart';
import 'package:novel_v3/core/models/novel.dart';

class SearchResultScreen extends StatelessWidget {
  final String title;
  final List<Novel> list;
  final void Function(Novel novel) onClicked;
  const SearchResultScreen({
    super.key,
    required this.title,
    required this.list,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: CustomScrollView(slivers: [_getListWidget()]),
    );
  }

  Widget _getListWidget() {
    return SliverListStyle(list: list, onClicked: onClicked);
  }
}
