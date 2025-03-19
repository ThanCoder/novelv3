import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/dialogs/download_dialog.dart';
import 'package:novel_v3/app/services/dio_services.dart';
import 'package:novel_v3/app/services/mediafire_services.dart';
import 'package:novel_v3/app/utils/app_util.dart';
import 'package:novel_v3/app/widgets/core/t_loader.dart';

class MediafireDownloaderDialog extends StatefulWidget {
  String url;
  String saveDirPath;
  bool isDownloadConfirm;
  void Function() onSuccess;
  MediafireDownloaderDialog({
    super.key,
    required this.url,
    required this.saveDirPath,
    this.isDownloadConfirm = true,
    required this.onSuccess,
  });

  @override
  State<MediafireDownloaderDialog> createState() =>
      _MediafireDownloaderDialogState();
}

class _MediafireDownloaderDialogState extends State<MediafireDownloaderDialog> {
  bool isLoading = false;
  String title = '';
  String downloadUrl = '';

  Widget _getContentSize(String url) {
    return FutureBuilder(
      future: DioServices.instance.getContentSize(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(width: 30, height: 30, child: TLoader(size: 30));
        }
        if (snapshot.hasData) {
          final data = snapshot.data ?? 0;
          return Text(
              'Size: ${AppUtil.instance.getParseFileSize(data.toDouble())}');
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _getContentWidget() {
    return FutureBuilder(
      future: MediafireServices.fetchDirectDownloadLink(widget.url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          isLoading = true;
          return Column(
            children: [TLoader(), const Text('ပြင်ဆင်နေပါတယ်...')],
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          isLoading = false;
        }
        if (snapshot.hasData) {
          final data = snapshot.data!;
          title = data.title;
          downloadUrl = data.downloadUrl;
          return Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${data.title}'),
              _getContentSize(
                  DioServices.instance.getForwardProxyUrl(data.downloadUrl)),
              Text(
                'Download Url: ${data.downloadUrl}',
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ],
          );
        }
        if (snapshot.hasError) {
          return Text('error: ${snapshot.error}');
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _download() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DownloadDialog(
        title: 'Downloader',
        url: DioServices.instance.getForwardProxyUrl(downloadUrl),
        saveFullPath: '${widget.saveDirPath}/$title.pdf',
        message: title,
        onError: (msg) {
          showDialogMessage(context, msg);
        },
        onSuccess: () {
          Navigator.pop(context);
          widget.onSuccess();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: _getContentWidget(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (isLoading) {
              showDialogMessage(context, 'ခဏစောင့်ပေးပါ...');
              return;
            }
            if (downloadUrl.isEmpty) {
              showDialogMessage(context, 'download url မရှိပါ...');
              return;
            }
            Navigator.pop(context);
            _download();
          },
          child: const Text('Download'),
        ),
      ],
    );
  }
}
