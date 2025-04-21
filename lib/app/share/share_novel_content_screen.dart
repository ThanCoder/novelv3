import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/core/index.dart';
import 'package:novel_v3/app/dialogs/index.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/services/core/index.dart';
import 'package:novel_v3/app/share/share_file.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:novel_v3/app/widgets/core/index.dart';

import 'share_file_type.dart';

class ShareNovelContentScreen extends StatefulWidget {
  String url;
  NovelModel novel;
  ShareNovelContentScreen({
    super.key,
    required this.url,
    required this.novel,
  });

  @override
  State<ShareNovelContentScreen> createState() =>
      _ShareNovelContentScreenState();
}

class _ShareNovelContentScreenState extends State<ShareNovelContentScreen> {
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
      List<dynamic> resList = jsonDecode(res.data.toString());
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
      child: Column(
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
    final dir = Directory(
        '${PathUtil.instance.getSourcePath()}/${file.getParentName()}');
    if (!dir.existsSync()) {
      dir.createSync();
    }
    final url = '${widget.url}/download?path=${file.path}';
    final savePath =
        '${PathUtil.instance.getSourcePath()}/${file.getParentName()}/${file.name}';
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
        '${PathUtil.instance.getSourcePath()}/${file.getParentName()}/${file.name}';
    return File(path).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 0,
      appBar: AppBar(
        title: const Text('Novel Content'),
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
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 3,
                          children: [
                            Text('Title: ${file.name.toCaptalize()}'),
                            Text('Type: ${file.type.name.toCaptalize()}'),
                            Text(
                                'Size: ${file.size.toDouble().toParseFileSize()}'),
                            Text(
                                'Date: ${DateTime.fromMillisecondsSinceEpoch(file.date).toParseTime()}'),
                            Text(
                                'Ago: ${DateTime.fromMillisecondsSinceEpoch(file.date).toTimeAgo()}'),
                            IconButton(
                              onPressed: () {
                                if (isExistsFile(file)) {
                                  _downloadConfirm(file);
                                } else {
                                  _download(file);
                                }
                              },
                              icon: Icon(
                                isExistsFile(file)
                                    ? Icons.download_done
                                    : Icons.download,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                ],
              ),
            ),
    );
  }
}
