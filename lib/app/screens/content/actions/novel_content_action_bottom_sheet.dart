import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/dialogs/core/index.dart';
import 'package:novel_v3/app/services/core/index.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:novel_v3/my_libs/fetcher/description_online_fetcher_dialog.dart';
import 'package:novel_v3/my_libs/novel_data/data_export_dialog.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/screens/forms/novel_edit_form_screen.dart';
import 'package:novel_v3/app/screens/pdf_scanner_screen.dart';
import 'package:novel_v3/my_libs/t_history_v1.0.0/t_history_record.dart';
import 'package:novel_v3/my_libs/t_history_v1.0.0/t_history_services.dart';
import 'package:novel_v3/my_libs/t_history_v1.0.0/t_methods.dart';

class NovelContentActionBottomSheet extends ConsumerStatefulWidget {
  void Function()? onBackpress;
  void Function(bool isLoading)? onLoading;
  NovelContentActionBottomSheet({
    super.key,
    this.onBackpress,
    this.onLoading,
  });

  @override
  ConsumerState<NovelContentActionBottomSheet> createState() =>
      _NovelContentActionBottomSheetState();
}

class _NovelContentActionBottomSheetState
    extends ConsumerState<NovelContentActionBottomSheet> {
  void _goEditScreen() {
    final novel = ref.read(novelNotifierProvider.notifier).getCurrent;
    if (novel == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelEditFormScreen(novel: novel),
      ),
    );
  }

  void _deleteConfirm() {
    final provider = ref.read(novelNotifierProvider.notifier);
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
            if (widget.onLoading != null) {
              widget.onLoading!(true);
            }
            //remove ui
            await provider.removeUI(novel);

            //remove db
            await novel.delete();

            await Future.delayed(const Duration(milliseconds: 600));
            
            //set history
            await THistoryServices.instance.add(
              THistoryRecord.create(
                  title: novel.title,
                  method: TMethods.delete,
                  desc: 'Novel Deleted'),
            );

            if (widget.onLoading != null) {
              widget.onLoading!(false);
            }

            if (widget.onBackpress != null) {
              widget.onBackpress!();
            }
            await ref.read(bookmarkNotifierProvider.notifier).initList();
            await ref.read(recentNotifierProvider.notifier).initList();

          } catch (e) {
            if (!mounted) return;
            showDialogMessage(context, e.toString());
          }
        },
      ),
    );
  }

  void _addPdfFromScanner() {
    final provider = ref.read(novelNotifierProvider.notifier);
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

  void _exportDataFile() {
    final provider = ref.read(novelNotifierProvider.notifier);
    final novel = provider.getCurrent;
    if (novel == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DataExportDialog(
        novelPath: novel.path,
        onDone: (savedPath) {
          //set record
          THistoryServices.instance.add(THistoryRecord.create(
            title: novel.title,
            method: TMethods.export,
            desc: 'Date Exportd path:`$savedPath`',
          ));
          showDialogMessage(context, '`$savedPath` Exported');
        },
      ),
    );
  }

  Future<void> _exportDataConfig() async {
    final provider = ref.read(novelNotifierProvider.notifier);
    final novel = provider.getCurrent;
    if (novel == null) return;
    if (!await checkStoragePermission()) return;
    novel.exportConfig(Directory(PathUtil.getOutPath()));
    showMessage(context, 'Exported', oldStyle: true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                goChapterEditForm(context, ref);
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
                      final provider = ref.read(novelNotifierProvider.notifier);
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
            ListTile(
              leading: const Icon(Icons.import_export_rounded),
              title: const Text('Data ထုတ်မယ်'),
              onTap: () {
                Navigator.pop(context);
                _exportDataFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.import_export_rounded),
              title: const Text('Data Config ထုတ်မယ်'),
              onTap: () {
                Navigator.pop(context);
                _exportDataConfig();
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
    );
  }
}
