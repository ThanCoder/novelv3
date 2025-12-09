import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/share/libs/share_grid_item.dart';
import 'package:novel_v3/app/others/share/libs/share_novel.dart';
import 'package:novel_v3/app/others/share/libs/share_novel_extension.dart';
import 'package:novel_v3/app/others/share/receive/novel_content_screen.dart';
import 'package:novel_v3/app/others/share/receive/novel_search_screen.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:t_client/t_client.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelReceiveScreen extends StatefulWidget {
  final String hostUrl;
  const NovelReceiveScreen({super.key, required this.hostUrl});

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
  final client = TClient();
  final tags = ['Latest', 'Completed', 'OnGoing', 'Adult', 'Not Adult'];
  String currentTag = 'Latest';

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      final res = await client.get('${widget.hostUrl}/api');
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
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CustomScrollView(
            slivers: [_getAppBar(), _getTags(), _getListWidget()],
          ),
        ),
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

  Widget _getTags() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: tags
              .map(
                (e) => TChip(
                  avatar: currentTag == e ? Icon(Icons.check) : null,
                  title: Text(e),
                  onClick: () {
                    setState(() {
                      currentTag = e;
                    });
                  },
                ),
              )
              .toList(),
        ),
      ),
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
    // tags
    final result = list.where((e) {
      if (currentTag == 'OnGoing' && !e.isCompleted) {
        return true;
      }
      if (currentTag == 'Completed' && e.isCompleted) {
        return true;
      }
      if (currentTag == 'Adult' && e.isAdult) {
        return true;
      }

      if (currentTag == 'Not Adult' && !e.isAdult) {
        return true;
      }
      if (currentTag == 'Latest') {
        return true;
      }
      return false;
    }).toList();
    return SliverGrid.builder(
      itemCount: result.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 130,
        mainAxisExtent: 160,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (context, index) => ShareGridItem(
        hostUrl: widget.hostUrl,
        novel: result[index],
        onClicked: _goContentPage,
      ),
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
        hostUrl: widget.hostUrl,
        list: list,
        onClicked: _goContentPage,
      ),
    );
  }

  void _goContentPage(ShareNovel novel) {
    goRoute(
      context,
      builder: (context) =>
          NovelContentScreen(hostUrl: widget.hostUrl, novel: novel),
    );
  }
}
