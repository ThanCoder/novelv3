import 'package:flutter/material.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:novel_v3/app/screens/forms/edit_novel_form.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import '../novel_dir_app.dart';

class NovelSeeAllView extends StatefulWidget {
  String title;
  List<Novel> list;
  EdgeInsetsGeometry padding;
  NovelSeeAllView({
    super.key,
    required this.title,
    required this.list,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  State<NovelSeeAllView> createState() => _NovelSeeAllViewState();
}

class _NovelSeeAllViewState extends State<NovelSeeAllView> {
  List<Novel> list = [];
  @override
  void initState() {
    list = widget.list;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: SeeAllView<Novel>(
        itemWidth: 140,
        itemHeight: 160,
        title: widget.title,
        list: list,
        showMoreButtonBottomPos: false,
        onSeeAllClicked: (title, list) =>
            goNovelSeeAllScreen(context, title, list),
        gridItemBuilder: (context, item) => NovelGridItem(
          novel: item,
          onClicked: (novel) => goNovelContentScreen(context, novel),
          onRightClicked: _showItemMenu,
        ),
      ),
    );
  }

  void _showItemMenu(Novel novel) {
    showTMenuBottomSheet(
      context,
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(novel.title)),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit_document),
          title: Text('Edit'),
          onTap: () {
            closeContext(context);
            _goEditScreen(novel);
          },
        ),
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever_rounded),
          title: Text('Delete'),
          onTap: () {
            closeContext(context);
            _deleteConfirm(novel);
          },
        ),
      ],
    );
  }

  void _goEditScreen(Novel novel) {
    goRoute(context, builder: (context) => EditNovelForm(novel: novel));
  }

  void _deleteConfirm(Novel novel) {
    showTConfirmDialog(
      context,
      submitText: 'Delete Forever',
      contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
      onSubmit: () {
        context.read<NovelProvider>().delete(novel);
      },
    );
  }
}
