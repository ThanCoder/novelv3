import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class PageUrlIconButton extends StatelessWidget {
  final List<String> list;
  const PageUrlIconButton({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog.adaptive(
            title: Text('Page Url'),
            scrollable: true,
            content: Column(
              children: List.generate(list.length, (index) {
                final url = list[index];
                return ListTile(
                  title: Text(
                    url,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    try {
                      ThanPkg.platform.launch(url);
                    } catch (e) {
                      showTMessageDialogError(context, e.toString());
                    }
                  },
                );
              }),
            ),
          ),
        );
      },
      icon: Icon(Icons.open_in_browser_rounded),
    );
  }
}
