import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

import '../models/uploader_file.dart';

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
          child: Row(
            spacing: 5,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Text(file.name),
                    Text('Type: ${file.type.name.toCaptalize()}'),
                    Text('Size: ${file.fileSize}'),
                    Text('ရက်စွဲ: ${file.date.toParseTime()}'),
                    // download
                    IconButton(
                      color: Colors.teal,
                      onPressed: () => onClicked(file),
                      icon: Icon(Icons.download),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
