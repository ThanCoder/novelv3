import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../../core/models/uploader_file.dart';

class OnlineFileListItem extends StatelessWidget {
  UploaderFile file;
  void Function(UploaderFile file) onClicked;
  OnlineFileListItem({super.key, required this.file, required this.onClicked});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                Text(
                  file.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
                Text('Type: ${file.type.name.toCaptalize()}'),
                Text('Size: ${file.fileSize}'),
                Text('ရက်စွဲ: ${file.date.toParseTime()}'),
                Text('Direct Link: ${file.isDirectLink ? 'Yes' : 'No'}'),
                _getDesc(file),
                // download
                IconButton(
                  color: Colors.teal,
                  onPressed: () => onClicked(file),
                  icon: Icon(Icons.download),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getDesc(UploaderFile file) {
    return SizedBox.shrink();
  }
}
