import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/share/libs/share_dir_file.dart';
import 'package:novel_v3/app/others/share/receive/client_download_manager.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/path_util.dart';
import 'package:t_client/t_client.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ContentList extends StatefulWidget {
  final String hostUrl;
  final List<ShareDirFile> list;
  const ContentList({super.key, required this.hostUrl, required this.list});

  @override
  State<ContentList> createState() => _ContentListState();
}

class _ContentListState extends State<ContentList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      // primary: false,
      // physics: NeverScrollableScrollPhysics(),
      itemCount: widget.list.length,
      itemBuilder: (context, index) => _getListItem(widget.list[index]),
    );
  }

  Widget _getListItem(ShareDirFile file) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          spacing: 8,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: TCacheImage(
                url: '${widget.hostUrl}/cover?path=${file.path}',
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Row(
                    children: [
                      Icon(Icons.title),
                      Expanded(
                        child: Text(
                          file.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(children: [Icon(Icons.sd_storage), Text(file.size)]),
                  file.mime.isEmpty
                      ? SizedBox()
                      : Row(
                          children: [
                            Icon(Icons.file_present_outlined),
                            Text(file.mime),
                          ],
                        ),
                  Row(
                    children: [
                      Icon(Icons.date_range),
                      Expanded(
                        child: Text(
                          file.date.toParseTime(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.download),
                      ElevatedButton(
                        onPressed: () => _onDowload(file),
                        child: Text('Download'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDowload(ShareDirFile file) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TMultiDownloaderDialog(
        manager: ClientDownloadManager(
          token: TClientToken(isCancelFileDelete: false),
          saveDir: Directory(PathUtil.getOutPath()),
        ),
        urls: ['${widget.hostUrl}/download?path=${file.path}'],
      ),
    );
  }
}
