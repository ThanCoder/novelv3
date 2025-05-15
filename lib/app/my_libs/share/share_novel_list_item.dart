import 'package:flutter/material.dart';
import 'package:novel_v3/app/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';

import 'share_file.dart';

class ShareNovelListItem extends StatelessWidget {
  String url;
  ShareFile file;
  bool isFileExists;
  void Function(ShareFile file) onDownloadClicked;
  ShareNovelListItem({
    super.key,
    required this.url,
    required this.file,
    required this.isFileExists,
    required this.onDownloadClicked,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = '$url/thumbnail?path=${file.path}';
    // print(thumbnailUrl);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 130, height: 150, child: MyImageUrl(url: thumbnailUrl)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text('Title: ${file.name.toCaptalize()}'),
                Text('Type: ${file.type.name.toCaptalize()}'),
                Text('Size: ${file.size.toDouble().toFileSizeLabel()}'),
                Text(
                    'Date: ${DateTime.fromMillisecondsSinceEpoch(file.date).toParseTime()}'),
                Text(
                    'Ago: ${DateTime.fromMillisecondsSinceEpoch(file.date).toTimeAgo()}'),
                IconButton(
                  onPressed: () => onDownloadClicked(file),
                  icon: Icon(
                    isFileExists ? Icons.download_done : Icons.download,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
