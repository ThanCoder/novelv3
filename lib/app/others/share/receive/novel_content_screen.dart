import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/providers/novel_provider.dart';
import 'package:novel_v3/core/services/novel_services.dart';
import 'package:novel_v3/app/others/share/libs/novel_file.dart';
import 'package:novel_v3/app/others/share/receive/client_download_manager.dart';
import 'package:novel_v3/app/others/share/receive/content_list.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:provider/provider.dart';
import 'package:t_client/t_client.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelContentScreen extends StatefulWidget {
  final String hostUrl;
  final Novel novel;
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
  List<NovelFile> list = [];
  final client = TClient();
  int sortId = 0;
  bool sortIsAsc = true;

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      final res = await client.get(
        '${widget.hostUrl}/api/view/novel/${widget.novel.id}',
      );
      final map = jsonDecode(res.data.toString());
      List<dynamic> files = map['files'] ?? [];
      list = files.map((e) => NovelFile.fromMap(e)).toList();
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
      length: 2,
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
      // snap: true,
      // floating: true,
      expandedHeight: size.height * .7,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          // TImageUrl(url: '${widget.hostUrl}/cover/id/${widget.novel.id}'),
          CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: '${widget.hostUrl}/cover/id/${widget.novel.id}',
            placeholder: (context, url) => TLoader.random(),
            errorWidget: (context, url, error) =>
                Icon(Icons.broken_image_outlined),
          ),
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
      leading: IconButton(
        padding: EdgeInsets.all(0),
        onPressed: () => Navigator.pop(context),
        color: Colors.white,
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.7),
        ),
        icon: Icon(Icons.arrow_back),
      ),
      actions: [
        !TPlatform.isDesktop
            ? SizedBox.shrink()
            : IconButton(
                onPressed: init,
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                ),
                icon: Icon(Icons.refresh),
              ),
        IconButton(
          onPressed: _allDownloadConfirm,
          color: Colors.white,
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.7),
          ),
          icon: Icon(Icons.sim_card_download_outlined),
        ),
        IconButton(
          onPressed: _showSortDialog,
          color: Colors.white,
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.7),
          ),
          icon: Icon(Icons.sort),
        ),
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
        ],
      ),
    );
  }

  Widget _getTabView() {
    return TabBarView(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: _getDesc()),
        ContentList(
          hostUrl: widget.hostUrl,
          novelId: widget.novel.id,
          list: list,
        ),
      ],
    );
  }

  Widget _getDesc() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Title: ${widget.novel.meta.title}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _checkAlreadyNovel(),
          ),
        ),
        SliverToBoxAdapter(
          child: Text(widget.novel.meta.desc, style: TextStyle(fontSize: 16)),
        ),
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

  Widget _checkAlreadyNovel() {
    return FutureBuilder(
      future: NovelServices.existsNovel(widget.novel.meta.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TLoader();
        }
        if (snapshot.data ?? false) {
          return Text(
            'App ထဲမှာ Novel ရှိနေပြီးသားပါ...',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          );
        }
        return Text(
          'App ထဲမှာ Novel မရှိပါ...',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        );
      },
    );
  }

  void _onSort() {
    // if (sortId == 0) {
    //   list.sortDate(isNewest: sortIsAsc);
    // }
    // if (sortId == 1) {
    //   list.sortAZ(isAToZ: sortIsAsc);
    // }
    // if (sortId == 2) {
    //   //pdf
    //   list.sortPdf(isPDF: sortIsAsc);
    // }
    // if (sortId == 3) {
    //   // chapter
    //   list.sortChapter(isChapter: sortIsAsc);
    // }
    // if (sortId == 4) {
    //   // config
    //   list.sortConfigFile(isConfigFile: sortIsAsc);
    // }

    // setState(() {});
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
      contentText:
          '"New ID Download": က ID အသစ်အနေနဲ့ Download လုပ်မယ်။\n"Download": က ရိုးရိုးပဲ လုပ်မယ်။',
      submitText: 'Download',
      cancelText: 'New ID Download',
      onSubmit: _allDownload,
      onCancel: () => _allDownload(isNewIdDownload: true),
    );
  }

  void _allDownload({bool isNewIdDownload = false}) async {
    var novel = await NovelServices.createNovelFolder(
      meta: widget.novel.meta,
      oldId: widget.novel.meta.id,
    );
    if (isNewIdDownload) {
      novel = await NovelServices.createNovelFolder(meta: widget.novel.meta);
    }
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TMultiDownloaderDialog(
        manager: ClientDownloadManager(
          token: TClientToken(isCancelFileDelete: false),
          saveDir: Directory(novel.path),
        ),
        urls: list
            .map(
              (e) =>
                  '${widget.hostUrl}/download/id/${widget.novel.id}/name/${e.name}',
            )
            .toList(),
        onSuccess: () {
          if (!mounted) return;
          context.read<NovelProvider>().init(isUsedCache: false);
          setState(() {});
        },
      ),
    );
  }
}
