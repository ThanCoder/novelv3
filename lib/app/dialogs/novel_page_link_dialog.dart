import 'package:flutter/material.dart';
import 'package:novel_v3/app/services/core/app_services.dart';

class NovelPageLinkDialog extends StatefulWidget {
  String pageUrl;
  void Function(String url) onClick;
  NovelPageLinkDialog({
    super.key,
    required this.pageUrl,
    required this.onClick,
  });

  @override
  State<NovelPageLinkDialog> createState() => _NovelPageLinkDialogState();
}

class _NovelPageLinkDialogState extends State<NovelPageLinkDialog> {
  @override
  void initState() {
    super.initState();
    init();
  }

  List<String> pageList = [];

  void init() {
    try {
      setState(() {
        pageList =
            widget.pageUrl.split(',').where((url) => url.isNotEmpty).toList();
      });
    } catch (e) {
      debugPrint('NovelPageLinkDialog:init ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Page Link'),
      content: SingleChildScrollView(
        child: Column(
          children: List.generate(
            pageList.length,
            (index) {
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
      ),
    );
  }
}
