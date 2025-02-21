import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/services/core/recent_db_services.dart';
import 'package:novel_v3/app/utils/path_util.dart';

class DownloadProgressDialog extends StatefulWidget {
  List<String> pathUrlList;
  String saveDirPath;
  BuildContext dialogContext;
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
    required this.dialogContext,
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
  String title = '';
  int max = 0;
  int progress = 0;
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
        max = widget.pathUrlList.length;
      });
      // List<Future<void>> downloadTasks =
      //     widget.pathUrlList.map((path) async {}).toList();
      for (var path in widget.pathUrlList) {
        try {
          if (isCanceled) break;

          final urlPath = '$api/download?path=$path';
          final savePath =
              '${createDir(widget.saveDirPath)}/${getBasename(path)}';

          // print('/url $urlPath \nsavePath $savePath');
          //download url
          await dio.download(urlPath, savePath);
          //progress
          setState(() {
            progress++;
            title = 'downloaded: ${getBasename(path)}';
          });
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
    Navigator.pop(widget.dialogContext);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 120,
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress / max,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(isLoading ? 'Loading...' : title)),
                const Spacer(),
                Text('$progress/$max'),
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
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
