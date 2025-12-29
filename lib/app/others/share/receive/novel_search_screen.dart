import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/others/share/libs/share_grid_item.dart';
import 'package:t_widgets/t_widgets.dart';

class NovelSearchScreen extends StatefulWidget {
  final String hostUrl;
  final List<Novel> list;
  final void Function(Novel novel)? onClicked;
  const NovelSearchScreen({
    super.key,
    required this.hostUrl,
    required this.list,
    this.onClicked,
  });

  @override
  State<NovelSearchScreen> createState() => _NovelSearchScreenState();
}

class _NovelSearchScreenState extends State<NovelSearchScreen> {
  List<Novel> result = [];
  bool isLoading = false;
  Timer? delayTime;
  int delayMili = 1200;

  @override
  void dispose() {
    if (delayTime?.isActive ?? false) {
      delayTime?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TScaffold(
      body: CustomScrollView(
        slivers: [_appBar(), _searchBar(), _loadingWidget(), _getList()],
      ),
    );
  }

  Widget _appBar() {
    return SliverAppBar(title: Text('Search...'));
  }

  Widget _searchBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      snap: true,
      floating: true,
      flexibleSpace: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TSearchField(
          hintText: 'Search Novel...',
          onChanged: (text) {
            if (!isLoading) {
              setState(() {
                isLoading = true;
              });
            }
            if (delayTime?.isActive ?? false) {
              delayTime?.cancel();
            }
            delayTime = Timer(Duration(milliseconds: delayMili), () {
              _onSearch(text);
            });
          },
        ),
      ),
    );
  }

  Widget _loadingWidget() {
    return SliverToBoxAdapter(
      child: isLoading
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              margin: EdgeInsets.only(bottom: 10),
              child: LinearProgressIndicator(),
            )
          : null,
    );
  }

  Widget _getList() {
    return SliverGrid.builder(
      itemCount: result.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisExtent: 200,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemBuilder: (context, index) => ShareGridItem(
        hostUrl: widget.hostUrl,
        novel: result[index],
        onClicked: widget.onClicked,
      ),
    );
  }

  void _onSearch(String text) {
    result = widget.list
        .where((e) => e.meta.title.toLowerCase().contains(text.toLowerCase()))
        .toList();
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }
}
