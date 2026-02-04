import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/services/novel_services.dart';
import 'package:novel_v3/app/others/share/libs/novel_file.dart';
import 'package:novel_v3/app/others/share/receive/client_download_manager.dart';
import 'package:t_client/t_client.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ContentListItem extends StatefulWidget {
  final NovelFile file;
  final String hostUrl;
  final String novelId;
  const ContentListItem({
    super.key,
    required this.novelId,
    required this.hostUrl,
    required this.file,
  });

  @override
  State<ContentListItem> createState() => _ContentListItemState();
}

class _ContentListItemState extends State<ContentListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          spacing: 8,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child:
                  // TCacheImage(
                  //   url:
                  //       '${widget.hostUrl}/cover/id/${widget.novelId}?name=${widget.file.name}',
                  // ),
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl:
                        '${widget.hostUrl}/cover/id/${widget.novelId}?name=${widget.file.name}',
                    placeholder: (context, url) => TLoader.random(),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.broken_image_outlined, size: 90),
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
                          widget.file.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.sd_storage),
                      Text(widget.file.size.toFileSizeLabel()),
                    ],
                  ),
                  widget.file.mime.isEmpty
                      ? SizedBox()
                      : Row(
                          children: [
                            Icon(Icons.file_present_outlined),
                            Text(widget.file.mime),
                          ],
                        ),
                  Row(
                    children: [
                      Icon(Icons.date_range),
                      Expanded(
                        child: Text(
                          widget.file.date.toParseTime(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  FutureBuilder(
                    future: isExists(),
                    builder: (context, snapshot) {
                      final isExists = snapshot.data ?? false;
                      // print('isExiss: $isExists - file: ${widget.file.name}');
                      return Row(
                        children: [
                          isExists
                              ? Icon(Icons.check, color: Colors.green)
                              : Icon(Icons.download, color: Colors.amber),
                          ElevatedButton(
                            onPressed: () =>
                                isExists ? __downloadConfirm() : _download(),
                            child: Text(isExists ? 'Downloaded' : 'Download'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> isExists() async {
    return await NovelServices.existsNovelOtherFile(
      widget.novelId,
      widget.file.name,
      checkSize: widget.file.size,
    );
  }

  void __downloadConfirm() {
    showTConfirmDialog(
      context,
      contentText: 'ပြန်ပြီး Download လုပ်ချင်ပါသလား?',
      submitText: 'ReDownload',
      onSubmit: () async {
        // delete file
        final novelPath = await NovelServices.getNovelFullPath(widget.novelId);
        final file = File(pathJoin(novelPath, widget.file.name));
        if (file.existsSync()) {
          await file.delete();
        }

        _download();
      },
    );
  }

  void _download() async {
    final novelPath = await NovelServices.getNovelFullPath(widget.novelId);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TMultiDownloaderDialog(
        manager: ClientDownloadManager(
          isExistsFileSkip: false,
          token: TClientToken(isCancelFileDelete: false),
          saveDir: Directory(novelPath),
        ),
        urls: [
          '${widget.hostUrl}/download/id/${widget.novelId}/name/${widget.file.name}',
        ],
        onSuccess: () {
          if (!mounted) return;
          setState(() {});
        },
        onError: (_) {
          if (!mounted) return;
          setState(() {});
        },
      ),
    );
  }
}
