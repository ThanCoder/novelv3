import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/utils/path_util.dart';

class NovelAllDownloadDialog extends StatefulWidget {
  NovelModel novel;
  List<String> downloadUrlList;
  void Function(String errorMsg) onClosed;

  NovelAllDownloadDialog({
    super.key,
    required this.novel,
    required this.downloadUrlList,
    required this.onClosed,
  });

  @override
  State<NovelAllDownloadDialog> createState() => _NovelAllDownloadDialogState();
}

class _NovelAllDownloadDialogState extends State<NovelAllDownloadDialog> {
  @override
  void initState() {
    downloadLength = widget.downloadUrlList.length;
    super.initState();
    init();
  }

  final dio = Dio();
  final CancelToken cancelToken = CancelToken();
  double fileSize = 0;
  double downloadedSize = 0;
  String progressMsg = 'ပြင်ဆင်နေပါတယ်...';
  String errorMsg = '';
  int downloadIndex = 0;
  int downloadLength = 0;

  void init() async {
    final dir =
        Directory('${PathUtil.instance.getSourcePath()}/${widget.novel.title}');
    if (!await dir.exists()) {
      await dir.create();
    }
    for (var url in widget.downloadUrlList) {
      progressMsg = 'Downloading : ${url.getName()}';
      downloadIndex++;
      final savedPath = '${dir.path}/${url.getName()}';
      final file = File(savedPath);
      if (await file.exists()) continue;
      if (!mounted) return;
      setState(() {});
      // await Future.delayed(const Duration(milliseconds: 400));
      await _download(url, savedPath);
    }
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    Navigator.pop(context);
    widget.onClosed(errorMsg);
  }

  Future<void> _download(String url, String savedPath) async {
    try {
      // download file
      await dio.download(
        Uri.encodeFull(url),
        savedPath,
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) {
          setState(() {
            fileSize = total.toDouble();
            downloadedSize = count.toDouble();
          });
        },
      );
    } catch (e) {
      errorMsg += '${e.toString()}\n';
    }
  }

  void _downloadCancel() {
    Navigator.pop(context);
    try {
      cancelToken.cancel();
    } catch (e) {
      errorMsg += '${e.toString()}\n';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('All Download'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text('$downloadLength/$downloadIndex'),
            Text(progressMsg),
            LinearProgressIndicator(
              value: fileSize == 0 ? null : downloadedSize / fileSize,
            ),
            //label
            fileSize == 0
                ? const SizedBox.shrink()
                : Text(
                    '${downloadedSize.toDouble().toParseFileSize()} / ${fileSize.toDouble().toParseFileSize()}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _downloadCancel();
          },
          child: const Text('Cancel'),
        ),
        // TextButton(
        //   onPressed:() {
        //           Navigator.pop(context);
        //         },
        //   child: const Text('Upgrade'),
        // ),
      ],
    );
  }
}
