import 'package:flutter/material.dart';
import 'package:t_widgets/functions/index.dart';
import 'package:than_pkg/than_pkg.dart';
import '../novel_v3_uploader.dart';

class OnlineNovelPageButton extends StatelessWidget {
  UploaderNovel novel;
  OnlineNovelPageButton({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    if (novel.getPageUrls.isEmpty) {
      return SizedBox.shrink();
    }
    return IconButton(
      onPressed: () {
        showTListDialog<String>(
          context,
          height: 200,
          list: novel.getPageUrls,
          listItemBuilder: (context, item) => ListTile(
            title: Text(item, maxLines: 3, style: TextStyle(fontSize: 13)),
            onTap: () async {
              try {
                await ThanPkg.platform.launch(item);
              } catch (e) {
                if (!context.mounted) return;
                showTMessageDialogError(context, e.toString());
              } finally {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        );
      },
      icon: Icon(Icons.open_in_browser),
    );
  }
}
