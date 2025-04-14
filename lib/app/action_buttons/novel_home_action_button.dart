import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/dialogs/core/index.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:provider/provider.dart';

class NovelHomeActionButton extends StatefulWidget {
  const NovelHomeActionButton({super.key});

  @override
  State<NovelHomeActionButton> createState() => _NovelHomeActionButtonState();
}

class _NovelHomeActionButtonState extends State<NovelHomeActionButton> {
  void _newNovel() {
    final provider = context.read<NovelProvider>();
    final list = provider.getList;
    showDialog(
      context: context,
      builder: (context) => RenameDialog(
        title: 'New Novel',
        onCheckIsError: (text) {
          final founds = list.where((nv) => nv.title == text);
          if (founds.isNotEmpty) {
            return 'Already Exists && Chooose Another Name!';
          }
          return null;
        },
        onCancel: () {},
        onSubmit: (title) {
          try {
            final novel = NovelModel.create(title.trim());
            provider.insertUI(novel);
            goNovelEditForm(context, novel);
          } catch (e) {
            showDialogMessage(context, e.toString());
          }
        },
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 150),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New Novel'),
                onTap: () {
                  Navigator.pop(context);
                  _newNovel();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showMenu,
      icon: const Icon(Icons.more_vert),
    );
  }
}
