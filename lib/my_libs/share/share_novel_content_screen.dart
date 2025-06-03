import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/core/index.dart';
import 'package:novel_v3/app/dialogs/index.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/services/core/index.dart';
import 'package:novel_v3/my_libs/share/novel_all_download_dialog.dart';
import 'package:novel_v3/my_libs/share/share_file.dart';
import 'package:novel_v3/my_libs/share/share_novel_list_item.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:t_widgets/t_widgets.dart';

import 'package:than_pkg/than_pkg.dart';

import 'share_file_type.dart';

class ShareNovelContentScreen extends ConsumerStatefulWidget {
  String url;
  NovelModel novel;
  ShareNovelContentScreen({
    super.key,
    required this.url,
    required this.novel,
  });

  @override
  ConsumerState<ShareNovelContentScreen> createState() =>
      _ShareNovelContentScreenState();
}

class _ShareNovelContentScreenState
    extends ConsumerState<ShareNovelContentScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  List<ShareFile> list = [];
  List<ShareFile> allList = [];
  bool isLoading = true;
  ShareFileType filterdType = ShareFileType.all;

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      final res = await DioServices.instance.getDio
          .get('${widget.url}/files?path=${widget.novel.path}');
      // List<dynamic> resList = jsonDecode(res.data.toString());
      List<dynamic> resList = res.data;
      allList = resList.map((map) => ShareFile.fromMap(map)).toList();
      list = allList;
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showDialogMessage(context, e.toString());
    }
  }

  void _filteredTypes() {
    if (filterdType == ShareFileType.all) {
      list = allList;
      setState(() {});
      return;
    }
    //filter
    list = allList.where((f) => f.type == filterdType).toList();
    setState(() {});
  }

  Widget _getFilterWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        spacing: 5,
        children: [
          // filter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Type'),
              DropdownButton<ShareFileType>(
                padding: const EdgeInsets.all(5),
                borderRadius: BorderRadius.circular(3),
                value: filterdType,
                items: ShareFileType.values
                    .map(
                      (type) => DropdownMenuItem<ShareFileType>(
                        value: type,
                        child: Text(type.name.toCaptalize()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    filterdType = value!;
                  });
                  _filteredTypes();
                },
              ),
            ],
          ),
          //all download
          TextButton(
            onPressed: _allDownload,
            child: const Text('All Download'),
          ),
        ],
      ),
    );
  }

  void _allDownload() {
    final urlList =
        allList.map((sf) => '${widget.url}/download?path=${sf.path}').toList();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NovelAllDownloadDialog(
        novel: widget.novel,
        downloadUrlList: urlList,
        onClosed: (errorMsg) {
          if (errorMsg.isNotEmpty) {
            showDialogMessage(context, errorMsg);
            return;
          }
          showMessage(context, 'Downloaded', oldStyle: true);
        },
      ),
    );
  }

  void _downloadConfirm(ShareFile file) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: '`${file.name}` ပြန်ပြီး download လုပ်ချင်ပါသလား?။',
        onCancel: () {},
        onSubmit: () => _download(file),
      ),
    );
  }

  void _download(ShareFile file) async {
    final dir =
        Directory('${PathUtil.getSourcePath()}/${file.getParentName()}');
    if (!dir.existsSync()) {
      dir.createSync();
    }
    final url = '${widget.url}/download?path=${file.path}';
    final savePath =
        '${PathUtil.getSourcePath()}/${file.getParentName()}/${file.name}';
    showDialog(
      context: context,
      builder: (context) => DownloadDialog(
        title: file.name,
        url: url,
        saveFullPath: savePath,
        message: file.name,
        onError: (msg) {
          showDialogMessage(context, msg);
        },
        onSuccess: () {
          setState(() {});
        },
      ),
    );
  }

  bool isExistsFile(ShareFile file) {
    final path =
        '${PathUtil.getSourcePath()}/${file.getParentName()}/${file.name}';
    return File(path).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    // print(allList.first.type);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.read(novelNotifierProvider.notifier).initList(isReset: true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.novel.title),
        ),
        body: isLoading
            ? TLoader()
            : RefreshIndicator(
                onRefresh: init,
                child: CustomScrollView(
                  slivers: [
                    // filter
                    SliverToBoxAdapter(
                      child: _getFilterWidget(),
                    ),

                    SliverList.separated(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final file = list[index];
                        return ShareNovelListItem(
                          url: widget.url,
                          file: file,
                          isFileExists: isExistsFile(file),
                          onDownloadClicked: (file) {
                            if (isExistsFile(file)) {
                              _downloadConfirm(file);
                            } else {
                              _download(file);
                            }
                          },
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
