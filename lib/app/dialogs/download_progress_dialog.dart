import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/services/core/recent_db_services.dart';
import 'package:novel_v3/app/utils/path_util.dart';

class DownloadProgressDialog extends StatefulWidget {
  List<String> pathUrlList;
  String saveDirPath;
  String title;
  String cancelText;
  String submitText;
  void Function() onSuccess;
  void Function() onCancaled;
  void Function(String msg) onError;

  DownloadProgressDialog({
    super.key,
    required this.pathUrlList,
    required this.saveDirPath,
    this.title = 'Downloader',
    this.cancelText = 'Cancel',
    this.submitText = 'Submit',
    required this.onSuccess,
    required this.onCancaled,
    required this.onError,
  });

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  @override
  void initState() {
    init();
    super.initState();
  }

  final dio = Dio();
  final CancelToken cancelToken = CancelToken();
  String title = '';
  int max = 0;
  int progress = 0;
  int downloadIndex = 0;
  int allFileCount = 0;
  bool isLoading = false;
  bool isCanceled = false;
  bool isError = false;
  String errMsg = '';

  void init() async {
    try {
      setState(() {
        isLoading = true;
      });

      final api = 'http://${getRecentDB<String>('server_address')}:$serverPort';
      //progress
      setState(() {
        isLoading = false;
        allFileCount = widget.pathUrlList.length;
      });
      // List<Future<void>> downloadTasks =
      //     widget.pathUrlList.map((path) async {}).toList();
      for (var path in widget.pathUrlList) {
        try {
          if (isCanceled) break;

          final urlPath = '$api/download?path=$path';
          final savePath =
              '${PathUtil.instance.createDir(widget.saveDirPath)}/${PathUtil.instance.getBasename(path)}';
          final saveFile = File(savePath);

          if (saveFile.existsSync()) {
            setState(() {
              progress++;
              title = PathUtil.instance.getBasename(path);
            });
          }
          //download file
          await dio.download(
            urlPath,
            savePath,
            cancelToken: cancelToken,
            onReceiveProgress: (count, total) {
              setState(() {
                setState(() {
                  max = total;
                  progress = count;
                });
              });
            },
          );
          //progress
          setState(() {
            downloadIndex++;
            title = PathUtil.instance.getBasename(path);
          });
          // await Future.delayed(const Duration(milliseconds: 100));
          // await Future.delayed(const Duration(milliseconds: 1200));
        } catch (e) {
          // debugPrint(e.toString());
          isError = true;
          errMsg += '\n${e.toString()}';
        }
      }
      //success
      _closeDialog();
      if (isCanceled) {
        widget.onCancaled();
      } else if (isError) {
        widget.onError(errMsg);
      } else {
        widget.onSuccess();
      }
    } catch (e) {
      widget.onError(e.toString());
      setState(() {
        isLoading = false;
      });
      _closeDialog();
    }
  }

  void _closeDialog() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          spacing: 10,
          children: [
            LinearProgressIndicator(
              value: max == 0 ? null : progress / max,
            ),
            Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isLoading ? 'Loading...' : title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('$downloadIndex/$allFileCount'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              isCanceled = true;
            });
            cancelToken.cancel();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
