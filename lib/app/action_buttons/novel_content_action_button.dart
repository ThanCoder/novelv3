import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/dialogs/core/index.dart';
import 'package:novel_v3/app/dialogs/description_online_fetcher_dialog.dart';
import 'package:novel_v3/app/provider/novel_bookmark_provider.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/screens/novel_edit_form_screen.dart';
import 'package:novel_v3/app/screens/pdf_scanner_screen.dart';
import 'package:provider/provider.dart';

class NovelContentActionButton extends StatefulWidget {
  VoidCallback? onBackpress;
  NovelContentActionButton({super.key, this.onBackpress});

  @override
  State<NovelContentActionButton> createState() =>
      _NovelContentActionButtonState();
}

class _NovelContentActionButtonState extends State<NovelContentActionButton> {
  void _goEditScreen() {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelEditFormScreen(novel: novel),
      ),
    );
  }

  void _deleteConfirm() {
    final provider = context.read<NovelProvider>();
    final novel = provider.getCurrent;
    if (novel == null) return;

    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: '`${novel.title}` ကိုဖျက်ချင်တာ သေချာပြီလား?`',
        submitText: 'Delete',
        onCancel: () {},
        onSubmit: () async {
          try {
            //remove ui
            provider.removeUI(novel);

            //remove db
            await novel.delete();
            await Future.delayed(const Duration(seconds: 1));
            context.read<NovelBookmarkProvider>().initList();

            if (widget.onBackpress != null) {
              widget.onBackpress!();
            }
          } catch (e) {
            if (!mounted) return;
            showDialogMessage(context, e.toString());
          }
        },
      ),
    );
  }

  void _addPdfFromScanner() {
    final provider = context.read<NovelProvider>();
    final novel = provider.getCurrent;
    if (novel == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfScannerScreen(
          novel: novel,
        ),
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 100,
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _goEditScreen();
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add Chapter'),
                onTap: () {
                  Navigator.pop(context);
                  goChapterEditForm(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _addPdfFromScanner();
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add Description From Online'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => DescriptionOnlineFetcherDialog(
                      onFetched: (text) {
                        final provider = context.read<NovelProvider>();
                        final novel = provider.getCurrent;
                        if (novel == null) return;
                        novel.content = text;
                        novel.save();
                        provider.setCurrent(novel);
                      },
                    ),
                  );
                },
              ),
              //delete
              ListTile(
                iconColor: Colors.red,
                leading: const Icon(Icons.delete_forever_rounded),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteConfirm();
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
