import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/dialogs/core/index.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/screens/novel_data_scanner.dart';

class NovelHomeActionButton extends ConsumerStatefulWidget {
  const NovelHomeActionButton({super.key});

  @override
  ConsumerState<NovelHomeActionButton> createState() =>
      _NovelHomeActionButtonState();
}

class _NovelHomeActionButtonState extends ConsumerState<NovelHomeActionButton> {
  void _newNovel() {
    final provider = ref.read(novelNotifierProvider.notifier);
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
            goNovelEditForm(context,ref, novel);
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
              ListTile(
                leading: const Icon(Icons.import_export),
                title: const Text('Import Data'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NovelDataScanner(),
                    ),
                  );
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
