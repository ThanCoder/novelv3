import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/services/core/app_services.dart';

class NovelPageLinkDialog extends StatefulWidget {
  BuildContext dialogContext;
  String pageUrl;
  void Function(String url) onClick;
  NovelPageLinkDialog({
    super.key,
    required this.dialogContext,
    required this.pageUrl,
    required this.onClick,
  });

  @override
  State<NovelPageLinkDialog> createState() => _NovelPageLinkDialogState();
}

class _NovelPageLinkDialogState extends State<NovelPageLinkDialog> {
  @override
  void initState() {
    init();
    super.initState();
  }

  List<String> pageList = [];

  void init() {
    try {
      final file = File(widget.pageUrl);
      final content = file.readAsStringSync();
      if (content.isEmpty) return;
      setState(() {
        pageList = content.split(',');
      });
    } catch (e) {
      debugPrint('NovelPageLinkDialog:init ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Page Link'),
      content: SizedBox(
        height: (MediaQuery.of(context).size.height / 100) * 40,
        width: (MediaQuery.of(context).size.width / 100) * 50,
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: pageList.length,
          itemBuilder: (context, index) {
            String title = pageList[index];
            return ListTile(
              onLongPress: () {
                Navigator.pop(context);
                copyText(title);
              },
              onTap: () {
                Navigator.pop(context);
                widget.onClick(title);
              },
              leading: const Icon(Icons.link),
              title: Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        ),
      ),
    );
  }
}
