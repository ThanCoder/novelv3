import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/action_buttons/novel_content_pdf_action_button.dart';
import 'package:novel_v3/app/components/pdf_list_item.dart';
import 'package:novel_v3/app/dialogs/core/confirm_dialog.dart';
import 'package:novel_v3/app/models/pdf_model.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/screens/content/background_scaffold.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:novel_v3/my_libs/pdf_readers_v1.0.1/dialogs/pdf_config_edit_dialog.dart';
import 'package:novel_v3/my_libs/t_history_v1.0.0/index.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../../components/core/index.dart';

class ContentPdfPage extends ConsumerStatefulWidget {
  const ContentPdfPage({super.key});

  @override
  ConsumerState<ContentPdfPage> createState() => _ContentPdfPageState();
}

class _ContentPdfPageState extends ConsumerState<ContentPdfPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    final novel = ref.read(novelNotifierProvider.notifier).getCurrent;
    if (novel == null) return;
    if (!mounted) return;
    ref
        .read(pdfNotifierProvider.notifier)
        .initList(novelPath: novel.path, isReset: true);
  }

  void _deleteConfirm(PdfModel pdf) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: '`${pdf.title}` ကိုဖျက်ချင်တာ သေချာပြီလား?`',
        submitText: 'Delete',
        onCancel: () {},
        onSubmit: () async {
          try {
            //ui
            ref.read(pdfNotifierProvider.notifier).delete(pdf);
            //set history
            THistoryServices.instance.add(THistoryRecord.create(
              title: pdf.title,
              method: TMethods.delete,
              desc: 'PDF Deleted',
            ));
          } catch (e) {
            if (!mounted) return;
            showDialogMessage(context, e.toString());
          }
        },
      ),
    );
  }

  void _restorePath(PdfModel pdf) {
    try {
      ref.read(pdfNotifierProvider.notifier).restore(pdf);
    } catch (e) {
      if (!mounted) return;
      showDialogMessage(context, e.toString());
    }
  }

  void _editConfig(PdfModel pdf) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PdfConfigEditDialog(
        value: pdf.getConfig(),
        onApply: (config) {
          pdf.setConfig(config);
        },
      ),
    );
  }

  void _showInfo(PdfModel pdf) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${pdf.title}'),
              Text('Size: ${pdf.size.toDouble().toFileSizeLabel()}'),
              Text('Date: ${pdf.date.toParseTime()}'),
              Text('Ago: ${pdf.date.toTimeAgo()}'),
              Text('Path: ${pdf.path}'),
            ],
          ),
        ),
      ),
    );
  }

  void _setCover(PdfModel pdf) async {
    final novel = ref.read(novelNotifierProvider.notifier).getCurrent;
    if (novel == null) return;

    final file = File(pdf.coverPath);
    if (!await file.exists()) return;
    // if (widget.novel == null) return;
    final coverPath = novel.coverPath;

    if (coverPath.isEmpty) return;
    await file.copy(coverPath);
    await clearAndRefreshImage();

    ref.read(novelNotifierProvider.notifier).setCurrent(novel);

    if (!mounted) return;
    showMessage(context, 'Cover Added');
  }

  void _showContextMenu(PdfModel pdf) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 100,
          ),
          child: Column(
            children: [
              //info
              ListTile(
                leading: const Icon(Icons.info_outlined),
                title: const Text('Infomation'),
                onTap: () {
                  Navigator.pop(context);
                  _showInfo(pdf);
                },
              ),

              ListTile(
                leading: const Icon(Icons.edit_document),
                title: const Text('Edit Config'),
                onTap: () {
                  Navigator.pop(context);
                  _editConfig(pdf);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_all),
                title: const Text('Copy Name'),
                onTap: () {
                  Navigator.pop(context);
                  copyText(pdf.title);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Set Cover'),
                onTap: () {
                  Navigator.pop(context);
                  _setCover(pdf);
                },
              ),
              ListTile(
                iconColor: Colors.yellow,
                leading: const Icon(Icons.restore),
                title: const Text('အပြင်ထုတ်'),
                onTap: () {
                  Navigator.pop(context);
                  _restorePath(pdf);
                },
              ),
              //delete
              ListTile(
                iconColor: Colors.red,
                leading: const Icon(Icons.delete_forever_rounded),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteConfirm(pdf);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fileDrops(List<String> pathList) async {
    final novel = ref.read(novelNotifierProvider.notifier).getCurrent;
    if (novel == null) return;
    //copy
    for (var path in pathList) {
      final file = File(path);
      //မရှိရင် , file မဟုတ်ရင် ကျော်မယ်
      if (!await file.exists() ||
          file.statSync().type != FileSystemEntityType.file) {
        continue;
      }
      //move
      final newPath = '${novel.path}/${file.getName()}';
      await file.rename(newPath);
    }
    //refresh
    ref
        .read(pdfNotifierProvider.notifier)
        .initList(novelPath: novel.path, isReset: true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(pdfNotifierProvider);
    final isLoading = provider.isLoading;
    final list = provider.list;
    return DropTarget(
      enable: true,
      onDragDone: (details) {
        if (details.files.isEmpty) return;
        final files = details.files.map((e) => e.path).toList();
        // ရှိပြီးသားကို စစ်ထုတ်မယ်
        final alreadyFiles = list.map((e) => e.title).toSet();
        final filterFiles = files
            .where((e) => !alreadyFiles.contains(e.getName(withExt: false)))
            .toList();
        _fileDrops(filterFiles);
      },
      child: BackgroundScaffold(
        stackChildren: [
          isLoading
              ? Center(child: TLoaderRandom())
              : RefreshIndicator(
                  onRefresh: init,
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor: const Color.fromARGB(0, 97, 97, 97),
                        title: const Text('PDF'),
                        actions: [
                          NovelContentPdfActionButton(),
                        ],
                      ),
                      SliverList.builder(
                        itemBuilder: (context, index) => PdfListItem(
                          pdf: list[index],
                          onClicked: (pdf) {
                            goPdfReader(context, ref, pdf);
                          },
                          onLongClicked: _showContextMenu,
                        ),
                        itemCount: list.length,
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
