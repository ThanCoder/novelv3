import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/share/libs/share_grid_item.dart';
import 'package:novel_v3/app/others/share/libs/share_novel.dart';
import 'package:novel_v3/app/others/share/libs/share_novel_extension.dart';
import 'package:novel_v3/app/others/share/novel_content_screen.dart';
import 'package:novel_v3/app/others/share/novel_search_screen.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/routes_helper.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelReceiveScreen extends StatefulWidget {
  final String url;
  const NovelReceiveScreen({super.key, required this.url});

  @override
  State<NovelReceiveScreen> createState() => _NovelReceiveScreenState();
}

class _NovelReceiveScreenState extends State<NovelReceiveScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  List<ShareNovel> list = [];
  bool isLoading = false;
  int sortId = 0;
  bool sortIsAsc = true;
  final Dio dio = Dio(
    BaseOptions(
      sendTimeout: Duration(seconds: 8),
      connectTimeout: Duration(seconds: 8),
      receiveTimeout: Duration(seconds: 8),
    ),
  );

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      final res = await dio.get('${widget.url}/api');
      List<dynamic> jsonList = jsonDecode(res.data.toString());
      list = jsonList.map((e) => ShareNovel.fromMap(e)).toList();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      _onSort();
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return TScaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: init,
        child: CustomScrollView(slivers: [_getAppBar(), _getListWidget()]),
      ),
    );
  }

  Widget _getAppBar() {
    return SliverAppBar(
      title: Text('Novel Share'),
      snap: true,
      floating: true,
      actions: [
        !TPlatform.isDesktop
            ? SizedBox.shrink()
            : IconButton(onPressed: init, icon: Icon(Icons.refresh)),
        IconButton(onPressed: _onSearch, icon: Icon(Icons.search)),
        IconButton(onPressed: _showSortDialog, icon: Icon(Icons.sort)),
      ],
    );
  }

  Widget _getListWidget() {
    if (isLoading) {
      return SliverFillRemaining(child: TLoader.random());
    }
    if (list.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('List Empty!'),
              IconButton(
                color: Colors.blue,
                onPressed: init,
                icon: Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      );
    }
    return SliverGrid.builder(
      itemCount: list.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 220,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemBuilder: (context, index) =>
          ShareGridItem(url: widget.url, novel: list[index]),
    );
  }

  // sort
  List<TSort> _getSortList() {
    return [
      TSort(id: 0, title: 'ရက်စွဲ', ascTitle: '^အသစ်', descTitle: 'အဟောင်း'),
      TSort(
        id: 1,
        title: 'Completed',
        ascTitle: '^Completed',
        descTitle: 'OnGoing',
      ),
      TSort(id: 2, title: 'Adult', ascTitle: '^Adult', descTitle: 'Not Adult'),
      TSort(id: 3, title: 'A-Z', ascTitle: '^A-Z', descTitle: 'Z-A'),
    ];
  }

  void _onSort() {
    if (sortId == 0) {
      list.sortDate(isNewest: sortIsAsc);
    }
    if (sortId == 1) {
      list.sortCompleted(isCompleted: sortIsAsc);
    }
    if (sortId == 2) {
      list.sortAdult(isAdult: sortIsAsc);
    }
    if (sortId == 3) {
      list.sortAZ(isAToZ: sortIsAsc);
    }
    setState(() {});
  }

  void _showSortDialog() {
    showTSortDialog(
      context,
      sortList: _getSortList(),
      isAsc: sortIsAsc,
      currentId: sortId,
      submitText: Text('ပြောင်းလဲမယ်'),
      sortDialogCallback: (id, isAsc) {
        sortId = id;
        sortIsAsc = isAsc;
        _onSort();
      },
    );
  }

  void _onSearch() {
    goRoute(
      context,
      builder: (context) => NovelSearchScreen(
        url: widget.url,
        list: list,
        onClicked: _goContentPage,
      ),
    );
  }

  void _goContentPage(ShareNovel novel) {
    goRoute(
      context,
      builder: (context) => NovelContentScreen(url: widget.url, novel: novel),
    );
  }
}
