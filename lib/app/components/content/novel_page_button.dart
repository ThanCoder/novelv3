import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelPageButton extends StatefulWidget {
  NovelModel novel;
  NovelPageButton({super.key, required this.novel});

  @override
  State<NovelPageButton> createState() => _NovelPageButtonState();
}

class _NovelPageButtonState extends State<NovelPageButton> {
  void _showDialog() {
    final list = widget.novel.getPageLinkList;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 3,
          children: List.generate(
            list.length,
            (index) {
              final url = widget.novel.getPageLinkList[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(url),
                    onTap: () {
                      Navigator.pop(context);
                      _openUrl(url);
                    },
                  ),
                  const Divider(),
                ],
              );
            },
          ),
        ),
      )),
    );
  }

  void _openUrl(String url) async {
    try {
      await ThanPkg.platform.launch(url);
    } catch (e) {
      if (!mounted) return;
      showDialogMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.novel.getPageLinkList.isEmpty) return const SizedBox.shrink();
    return ElevatedButton(
      onPressed: _showDialog,
      child: const Text('Page'),
    );
  }
}
