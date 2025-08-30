import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/share/libs/downloader_dialog.dart';
import 'package:novel_v3/app/share/libs/multi_downloader_dialog.dart';
import 'package:novel_v3/app/share/libs/share_dir_file.dart';
import 'package:novel_v3/app/share/libs/share_dir_file_extension.dart';
import 'package:novel_v3/app/share/libs/share_novel.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelContentScreen extends StatefulWidget {
  final String url;
  final ShareNovel novel;
  const NovelContentScreen({super.key, required this.url, required this.novel});

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
        '${widget.url}/dir/api?path=${widget.novel.path}',
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
    return TScaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: init,
        child: CustomScrollView(slivers: [_getAppBar(), _getListWidget()]),
      ),
    );
  }

  Widget _getAppBar() {
    return SliverAppBar(
      title: Text('Content: ${widget.novel.title}'),
      snap: true,
      floating: true,
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
              Text('List is Empty'),
              IconButton(onPressed: init, icon: Icon(Icons.refresh)),
            ],
          ),
        ),
      );
    }
    return SliverList.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => _getListItem(list[index]),
    );
  }

  Widget _getListItem(ShareDirFile file) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8,
          runSpacing: 5,
          children: [
            SizedBox(
              width: 100,
              height: 120,
              child: TCacheImage(
                url: '${widget.url}/cover?path=${file.path}',
                cachePath: PathUtil.getCachePath(),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                Text(
                  file.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Size: ${file.size}'),
                file.mime.isEmpty
                    ? SizedBox()
                    : Row(
                        children: [
                          Icon(Icons.file_present_outlined),
                          Text('Type: ${file.mime}'),
                        ],
                      ),
                Row(
                  children: [
                    Icon(Icons.date_range),
                    Text('ရက်စွဲ: ${file.date.toParseTime()}'),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _onDowload(file),
                      child: Row(
                        children: [Icon(Icons.download), Text('Download')],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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

  void _onDowload(ShareDirFile file) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DownloaderDialog(
        url: '${widget.url}/download?path=${file.path}',
        saveFullPath: PathUtil.getOutPath(name: file.name),
        filename: file.name,
        onSuccess: () {
          showTSnackBar(context, 'Downloaded');
        },
      ),
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
      builder: (context) => MultiDownloaderDialog(
        downloadUrlList: list
            .map((e) => '${widget.url}/download?path=${e.path}')
            .toList(),
        outDir: Directory(novelPath),
        onClosed: (errorMsg) {},
      ),
    );
  }
}
