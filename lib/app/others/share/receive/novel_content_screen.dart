import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/others/share/receive/client_download_manager.dart';
import 'package:novel_v3/app/others/share/libs/share_dir_file.dart';
import 'package:novel_v3/app/others/share/libs/share_dir_file_extension.dart';
import 'package:novel_v3/app/others/share/libs/share_novel.dart';
import 'package:novel_v3/app/others/share/receive/content_list.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:provider/provider.dart';
import 'package:t_client/t_client.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelContentScreen extends StatefulWidget {
  final String hostUrl;
  final ShareNovel novel;
  const NovelContentScreen({
    super.key,
    required this.hostUrl,
    required this.novel,
  });

  @override
  State<NovelContentScreen> createState() => _NovelContentScreenState();
}

class _NovelContentScreenState extends State<NovelContentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = false;
  List<ShareDirFile> list = [];
  final client = TClient();
  int sortId = 0;
  bool sortIsAsc = true;

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      final res = await client.get(
        '${widget.hostUrl}/dir/api?path=${widget.novel.path}',
      );
      List<dynamic> jsonList = jsonDecode(res.data.toString());
      list = jsonList.map((e) => ShareDirFile.fromMap(e)).toList();
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
    return DefaultTabController(
      length: 5,
      child: TScaffold(
        body: isLoading
            ? Center(child: TLoader.random())
            : RefreshIndicator.adaptive(
                onRefresh: init,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    _getAppBar(),
                    _getHeader(),
                  ],
                  body: _getTabView(),
                ),

                // CustomScrollView(
                //   slivers: [
                //     _getAppBar(),
                //     _getHeader(),
                //     SliverFillRemaining(
                //       fillOverscroll: true,
                //       child: _getTabView(),
                //     ),
                //   ],
                // ),
              ),
      ),
    );
  }

  Widget _getAppBar() {
    final size = MediaQuery.of(context).size;
    return SliverAppBar(
      title: Text('Content: ${widget.novel.title}'),
      // snap: true,
      // floating: true,
      expandedHeight: size.height * .5,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          TImageUrl(url: widget.novel.getCoverPath(widget.hostUrl)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Setting.getAppConfig.isDarkTheme
                      ? Colors.black.withValues(alpha: .5)
                      : Colors.white.withValues(alpha: .5),
                  Colors.transparent,
                  Setting.getAppConfig.isDarkTheme
                      ? Colors.black.withValues(alpha: .5)
                      : Colors.white.withValues(alpha: .5),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        !TPlatform.isDesktop
            ? SizedBox.shrink()
            : IconButton(onPressed: init, icon: Icon(Icons.refresh)),
        IconButton(
          onPressed: _allDownloadConfirm,
          icon: Icon(Icons.sim_card_download_outlined),
        ),
        IconButton(onPressed: _showSortDialog, icon: Icon(Icons.sort)),
      ],
    );
  }

  Widget _getHeader() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 5,
      snap: true,
      floating: true,
      pinned: false,
      bottom: TabBar(
        isScrollable: true,
        tabs: [
          Tab(text: 'Description'),
          Tab(text: 'အားလုံး'),
          Tab(text: 'PDF'),
          Tab(text: 'Chapter'),
          Tab(text: 'Config'),
        ],
      ),
    );
  }

  Widget _getTabView() {
    final pdfList = list.where((e) => e.mime.endsWith('pdf')).toList();
    final chapterList = list.where((e) => e.isChapterFile).toList();
    final configList = list.where((e) => e.isConfigFile).toList();
    return TabBarView(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: _getDesc()),
        ContentList(hostUrl: widget.hostUrl, list: list),
        ContentList(hostUrl: widget.hostUrl, list: pdfList),
        ContentList(hostUrl: widget.hostUrl, list: chapterList),
        ContentList(hostUrl: widget.hostUrl, list: configList),
      ],
    );
  }

  Widget _getDesc() {
    final descIndex = list.indexWhere((e) => e.name == 'content');
    if (descIndex == -1) return Center(child: Text('Description မရှိပါ!...'));
    final desc = list[descIndex];
    return FutureBuilder(
      future: client.get(desc.getDownloadLink(widget.hostUrl)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TLoader.random();
        }
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Text(
                  data.data.toString(),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        }
        return Center(child: Text('Description မရှိပါ!...'));
      },
    );
  }

  // sort
  List<TSort> _getSortList() {
    return [
      TSort(id: 0, title: 'ရက်စွဲ', ascTitle: '^အသစ်', descTitle: 'အဟောင်း'),
      TSort(id: 1, title: 'A-Z', ascTitle: '^A-Z', descTitle: 'Z-A'),
      TSort(id: 2, title: 'PDF', ascTitle: '^PDF', descTitle: 'Not PDF'),
      TSort(
        id: 3,
        title: 'Chapter',
        ascTitle: '^Chapter',
        descTitle: 'Not Chapter',
      ),
      TSort(
        id: 4,
        title: 'Config',
        ascTitle: '^Config',
        descTitle: 'Not Config',
      ),
    ];
  }

  void _onSort() {
    if (sortId == 0) {
      list.sortDate(isNewest: sortIsAsc);
    }
    if (sortId == 1) {
      list.sortAZ(isAToZ: sortIsAsc);
    }
    if (sortId == 2) {
      //pdf
      list.sortPdf(isPDF: sortIsAsc);
    }
    if (sortId == 3) {
      // chapter
      list.sortChapter(isChapter: sortIsAsc);
    }
    if (sortId == 4) {
      // config
      list.sortConfigFile(isConfigFile: sortIsAsc);
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

  void _allDownloadConfirm() {
    showTConfirmDialog(
      context,
      title: 'အတည်ပြုခြင်း',
      contentText: 'အားလုံးကို Downlaod ပြုလုပ်ချင်တာ သေချာပြီလား?',
      submitText: 'Download',
      onSubmit: _allDownload,
    );
  }

  void _allDownload() {
    final novelPath = PathUtil.createDir(
      '${PathUtil.getSourcePath()}/${widget.novel.title}',
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TMultiDownloaderDialog(
        manager: ClientDownloadManager(
          token: TClientToken(isCancelFileDelete: false),
          saveDir: Directory(novelPath),
        ),
        urls: list
            .map((e) => '${widget.hostUrl}/download?path=${e.path}')
            .toList(),
        onSuccess: () {
          if (!mounted) return;
          context.read<NovelProvider>().init(isUsedCache: false);
        },
      ),
    );
  }
}
