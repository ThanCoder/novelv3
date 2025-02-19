import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/components/pdf_list_view.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/dialogs/rename_dialog.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:novel_v3/app/screens/pdf_reader_screen.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';
import 'package:provider/provider.dart';

class PdfListPage extends StatefulWidget {
  const PdfListPage({super.key});

  @override
  State<PdfListPage> createState() => PdfListPageState();
}

class PdfListPageState extends State<PdfListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  late PdfFileModel pdfFile;

  void init() async {
    try {
      if (currentNovelNotifier.value == null) return;
      context.read<PdfProvider>().initList();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {},
        builder: (context) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text(pdfFile.title)),
            ),
            const Divider(),
            //copy name
            ListTile(
              onTap: () {
                Navigator.pop(context);
                copyText(pdfFile.title);
              },
              leading: const Icon(Icons.copy),
              title: const Text('copy name'),
            ),
            //rename
            ListTile(
              onTap: () {
                Navigator.pop(context);
                renamePdf();
              },
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('Rename'),
            ),
            //copy in novel
            ListTile(
              onTap: () {
                Navigator.pop(context);
                copyToOutDir();
              },
              leading: const Icon(Icons.copy),
              title: const Text('အပြင်ကို ကူးထုတ်မယ်'),
            ),
            //move out pdf
            ListTile(
              onTap: () {
                Navigator.pop(context);
                moveToOutDir();
              },
              leading: const Icon(Icons.move_down),
              title: const Text('အပြင်ကို ရွေ့ထုတ်မယ်(Move)'),
            ),
            //delete
            ListTile(
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                deletePdf();
              },
              leading: const Icon(Icons.delete_forever),
              title: const Text('ဖျက်မယ် (Delete)'),
            ),
          ],
        ),
      ),
    );
  }

  void renamePdf() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RenameDialog(
        renameLabelText: const Text('Rename PDF Title'),
        renameText: pdfFile.title.replaceAll('.pdf', ''),
        onCancel: () {},
        onSubmit: (title) {
          ctx.read<PdfProvider>().rename(pdfFile: pdfFile, renamedTitle: title);
        },
      ),
    );
  }

  void copyToOutDir() {
    try {
      final file = File(pdfFile.path);
      if (file.existsSync()) {
        file.copySync('${getOutPath()}/${pdfFile.title}');
        showMessage(
            context, 'ကူးယူပြီးပါပြီ။ Path: ${getOutPath()}/${pdfFile.title}');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void moveToOutDir() {
    try {
      final file = File(pdfFile.path);
      if (file.existsSync()) {
        file.renameSync('${getOutPath()}/${pdfFile.title}');
        //update ui
        final pdfList = pdfListNotifier.value
            .where((pdf) => pdf.title != pdfFile.title)
            .toList();
        pdfListNotifier.value = pdfList;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void deletePdf() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
        cancelText: 'မလုပ်ဘူး',
        submitText: 'ဖျက်မယ်',
        onCancel: () {},
        onSubmit: () async {
          try {
            final file = File(pdfFile.path);
            if (file.existsSync()) {
              file.deleteSync();
              //update ui
              final pdfList = pdfListNotifier.value
                  .where((pdf) => pdf.title != pdfFile.title)
                  .toList();
              pdfListNotifier.value = pdfList;
            }
          } catch (e) {
            debugPrint(e.toString());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PdfProvider>();
    final isLoading = provider.isLoading;
    final pdfList = provider.getList;

    if (isLoading) {
      return Center(
        child: TLoader(),
      );
    }
    if (pdfList.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("PDF List မရှိပါ"),
          IconButton(
            color: Colors.teal[900],
            onPressed: init,
            icon: const Icon(Icons.refresh),
          ),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 800));
        init();
      },
      child: PdfListView(
        controller: _scrollController,
        pdfList: pdfList,
        activeColor: Colors.teal[700],
        activeTitle: getRecentDB<String>(
                'pdf_list_page_${currentNovelNotifier.value!.title}') ??
            '',
        onClick: (pdfFile) {
          //set recent
          setRecentDB('pdf_list_page_${currentNovelNotifier.value!.title}',
              pdfFile.title);
          setState(() {});
          //go reader
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfReaderScreen(pdfFile: pdfFile),
            ),
          );
        },
        onLongClick: (_pdfFile) {
          pdfFile = _pdfFile;
          showMenu();
        },
      ),
    );
  }
}
