import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/providers/novel_provider.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_toggle_list_tile.dart';
import 'package:novel_v3/app/others/novl_db/novl_export_list_tile.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/forms/edit_novel_screen.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/functions/index.dart';

class NovelItemMenuActions extends StatefulWidget {
  final Novel novel;
  const NovelItemMenuActions({super.key, required this.novel});

  @override
  State<NovelItemMenuActions> createState() => _NovelItemMenuActionsState();
}

class _NovelItemMenuActionsState extends State<NovelItemMenuActions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Update'),
          onTap: () {
            closeContext(context);
            _onNovelEdit();
          },
        ),
        NovelBookmarkToggleListTile(
          novelTitle: widget.novel.meta.title,
          onClosed: () => closeContext(context),
        ),
        NovlExportListTile(
          novel: widget.novel,
          onClosed: () => closeContext(context),
        ),
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever),
          title: Text('Delete Forever'),
          onTap: () {
            _onDeleted();
          },
        ),
      ],
    );
  }

  void _onNovelEdit() {
    goRoute(
      context,
      builder: (context) => EditNovelScreen(
        novel: widget.novel,
        onUpdated: (updatedNovel) {
          context.read<NovelProvider>().update(updatedNovel);
        },
      ),
    );
  }

  void _onDeleted() {
    showTConfirmDialog(
      context,
      contentText: 'ဖျက်ချင်တာ သေချာပြီလား?\nပြန်လည်မရယူနိုင်ပါ!.',
      submitText: 'Delete Forever',
      barrierDismissible: false,
      onSubmit: () => _deleteForever(),
    );
  }

  void _deleteForever() async {
    if (!mounted) return;
    await context.read<NovelProvider>().deleteForever(widget.novel);
    if (!mounted) return;
    closeContext(context);
  }
}
