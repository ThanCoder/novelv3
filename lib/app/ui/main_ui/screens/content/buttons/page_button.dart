import 'package:flutter/material.dart';
import 'package:novel_v3/app/providers/novel_provider.dart';
import 'package:novel_v3/app/ui/main_ui/screens/content/page_url_dialog.dart';
import 'package:provider/provider.dart';
import 'package:than_pkg/than_pkg.dart';

class PageButton extends StatelessWidget {
  const PageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) {
      return SizedBox.shrink();
    }
    final list = novel.getPageUrls;
    if (list.isNotEmpty) {
      return TextButton(
        child: const Text('Page Url'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => PageUrlDialog(
              list: list,
              onClicked: (url) {
                try {
                  ThanPkg.platform.launch(url);
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
              onRightClicked: (url) {
                ThanPkg.appUtil.copyText(url);
              },
            ),
          );
        },
      );
    }
    return SizedBox.shrink();
  }
}
