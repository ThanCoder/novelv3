import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/share/receive/client_download_manager.dart';
import 'package:novel_v3/app/others/share/libs/share_dir_file.dart';
import 'package:novel_v3/app/others/share/libs/share_dir_file_extension.dart';
import 'package:novel_v3/app/others/share/libs/share_novel.dart';
import 'package:novel_v3/app/others/share/receive/content_list.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
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
  final Dio dio = Dio(
    BaseOptions(
      sendTimeout: Duration(seconds: 8),
      connectTimeout: Duration(seconds: 8),
      receiveTimeout: Duration(seconds: 8),
    ),
  );
  int sortId = 0;
  bool sortIsAsc = true;

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      final res = await dio.get(
        '${widget.hostUrl}/dir/api?path=${widget.novel.path}',
      );
      List<dynamic> jsonList = List<dynamic>.from(res.data);
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
      length: 4,
      child: TScaffold(
        body: isLoading
            ? Center(child: TLoader.random())
            : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [_getAppBar(), _getHeader()];
                },
                body: _getTabView(),
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
      expandedHeight: size.height * .6,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          TImage(source: widget.novel.getCoverPath(widget.hostUrl)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Setting.getAppConfig.isDarkMode
                      ? Colors.black.withValues(alpha: .5)
                      : Colors.white.withValues(alpha: .5),
                  Colors.transparent,
                  Setting.getAppConfig.isDarkMode
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
      bottom: TabBar(
        isScrollable: true,
        tabs: [
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
        ContentList(hostUrl: widget.hostUrl, list: list),
        ContentList(hostUrl: widget.hostUrl, list: pdfList),
        ContentList(hostUrl: widget.hostUrl, list: chapterList),
        ContentList(hostUrl: widget.hostUrl, list: configList),
      ],
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
      ),
    );
  }
}
