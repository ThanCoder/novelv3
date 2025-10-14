import 'package:flutter/material.dart';
import 'package:novel_v3/app/ui/routes_helper.dart';
import 'package:novel_v3/app/ui/main_ui/screens/forms/edit_novel_form.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

import '../../novel_dir_app.dart';

ValueNotifier<List<Novel>> novelSeeAllScreenNotifier = ValueNotifier([]);

class NovelSeeAllScreen extends StatefulWidget {
  String title;
  NovelSeeAllScreen({super.key, required this.title});

  @override
  State<NovelSeeAllScreen> createState() => _NovelSeeAllScreenState();
}

class _NovelSeeAllScreenState extends State<NovelSeeAllScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ValueListenableBuilder(
        valueListenable: novelSeeAllScreenNotifier,
        builder: (context, list, child) {
          return GridView.builder(
            itemCount: list.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisExtent: 200,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) => NovelGridItem(
              novel: list[index],
              onClicked: (novel) => goNovelContentScreen(context, novel),
              onRightClicked: _showItemMenu,
            ),
          );
        },
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
