import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/utils.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelPageComponent extends StatefulWidget {
  final Novel novel;
  const NovelPageComponent({super.key, required this.novel});

  @override
  State<NovelPageComponent> createState() => _NovelPageComponentState();
}

class _NovelPageComponentState extends State<NovelPageComponent> {
  @override
  void didUpdateWidget(covariant NovelPageComponent oldWidget) {
    if (oldWidget.novel.meta.pageUrls.length !=
        widget.novel.meta.pageUrls.length) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.novel.meta.pageUrls.isEmpty) return SizedBox.shrink();
    return IconButton(
      onPressed: _showGotoDialog,
      icon: Icon(Icons.open_in_browser),
    );
  }

  void _showGotoDialog() {
    showTMenuBottomSheet(
      context,
      title: Text('Page Urls'),
      children: List.generate(
        widget.novel.meta.pageUrls.length,
        (index) => _listItem(widget.novel.meta.pageUrls[index]),
      ),
    );
  }

  Widget _listItem(String url) {
    return InkWell(
      onSecondaryTap: () {
        try {
          ThanPkg.appUtil.copyText(url);
          if (TPlatform.isDesktop) {
            showTSnackBar(context, 'Url Copied');
          }
          context.closeNavigator();
        } catch (e) {
          showTMessageDialogError(context, e.toString());
        }
      },
      child: ListTile(
        title: Text(
          url,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11),
        ),
        onTap: () {
          try {
            ThanPkg.platform.launch(url);
            context.closeNavigator();
          } catch (e) {
            showTMessageDialogError(context, e.toString());
          }
        },
        onLongPress: () {
          try {
            ThanPkg.appUtil.copyText(url);
            if (TPlatform.isDesktop) {
              showTSnackBar(context, 'Url Copied');
            }
            context.closeNavigator();
          } catch (e) {
            showTMessageDialogError(context, e.toString());
          }
        },
      ),
    );
  }
}
