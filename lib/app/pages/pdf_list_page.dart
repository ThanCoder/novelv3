import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/components/pdf_list_view.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/dialogs/rename_dialog.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/screens/pdf_reader_screen.dart';
import 'package:novel_v3/app/services/app_services.dart';
import 'package:novel_v3/app/services/novel_services.dart';
import 'package:novel_v3/app/services/pdf_services.dart';
import 'package:novel_v3/app/services/recent_db_services.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';

class PdfListPage extends StatefulWidget {
  const PdfListPage({super.key});

  @override
  State<PdfListPage> createState() => PdfListPageState();
}

class PdfListPageState extends State<PdfListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    init();
    super.initState();
  }

  bool isLoading = false;
  late PdfFileModel pdfFile;

  void init() async {
    try {
      if (currentNovelNotifier.value == null) return;
      pdfListNotifier.value = [];
      setState(() {
        isLoading = true;
      });

      var pdfList =
          await getPdfList(sourcePath: currentNovelNotifier.value!.path);

      pdfList = await genPdfCover(pdfList: pdfList);

      //set
      pdfListNotifier.value = pdfList;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {},
        builder: (context) => SizedBox(
          height: 250,
          child: ListView(
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
      ),
    );
  }

  void renamePdf() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RenameDialog(
        dialogContext: context,
        renameLabelText: const Text('Rename PDF Title'),
        renameText: pdfFile.title.replaceAll('.pdf', ''),
        onCancel: () {},
        onSubmit: (text) {
          try {
            final file = File(pdfFile.path);
            if (file.existsSync()) {
              final newPath =
                  pdfFile.path.replaceAll(getBasename(file.path), '$text.pdf');
              pdfFile.changeFullPath(newPath);
              //update ui
              init();
            }
          } catch (e) {
            debugPrint(e.toString());
          }
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
        dialogContext: context,
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
    if (isLoading) {
      return Center(
        child: TLoader(),
      );
    } else {
      return ValueListenableBuilder(
        valueListenable: pdfListNotifier,
        builder: (context, value, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 800));
              init();
            },
            child: PdfListView(
              controller: _scrollController,
              pdfList: value,
              activeColor: Colors.teal[700],
              activeTitle: getRecentDB<String>(
                      'pdf_list_page_${currentNovelNotifier.value!.title}') ??
                  '',
              onClick: (pdfFile) {
                //set recent
                setRecentDB(
                    'pdf_list_page_${currentNovelNotifier.value!.title}',
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
        },
      );
    }
  }
}
