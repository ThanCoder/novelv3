import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/pages/pdf_scanner_page.dart';
import 'package:novel_v3/app/pdf_readers/pdfrx_reader.dart';
import 'package:novel_v3/app/services/novel_services.dart';
import 'package:novel_v3/app/utils/app_util.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';

class PdfAddFormScreen extends StatefulWidget {
  const PdfAddFormScreen({super.key});

  @override
  State<PdfAddFormScreen> createState() => _PdfAddFormScreenState();
}

class _PdfAddFormScreenState extends State<PdfAddFormScreen> {
  late PdfFileModel pdfFile;

  bool isLoading = false;

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
            //Info
            ListTile(
              onTap: () {
                Navigator.pop(context);
                pdfInfo(pdfFile);
              },
              leading: const Icon(Icons.info_outline),
              title: const Text('Info'),
            ),
            //open
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfrxReader(pdfFile: pdfFile),
                  ),
                );
              },
              leading: const Icon(Icons.open_in_browser),
              title: const Text('Open'),
            ),
            //move in novel
            ListTile(
              onTap: () {
                Navigator.pop(context);
                moveToNovel();
              },
              leading: const Icon(Icons.move_to_inbox),
              title: const Text('Novel ထဲကို ရွှေ့မယ်(Move)'),
            ),
            //copy in novel
            ListTile(
              onTap: () {
                Navigator.pop(context);
                copyToNovel();
              },
              leading: const Icon(Icons.copy),
              title: const Text('Novel ထဲကို ကူးမယ်(Copy)'),
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

  void moveToNovel() {
    try {
      final novel = currentNovelNotifier.value;
      final file = File(pdfFile.path);
      if (file.existsSync() && novel != null) {
        //new path
        final newPath = '${novel.path}/${getBasename(file.path)}';
        file.renameSync(newPath);
        //change pdf scanner ui
        final pdfScannerList = pdfScannerListNotifier.value
            .where((pdf) => pdf.title != pdfFile.title)
            .toList();
        pdfScannerListNotifier.value = pdfScannerList;

        //change pdf list ui
        final pdfList = pdfListNotifier.value;
        pdfListNotifier.value = [];
        pdfFile.path = newPath;
        pdfList.insert(0, pdfFile);
        pdfListNotifier.value = pdfList;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void copyToNovel() async {
    try {
      try {
        final novel = currentNovelNotifier.value;
        final file = File(pdfFile.path);
        if (file.existsSync() && novel != null) {
          final newPath = '${novel.path}/${getBasename(file.path)}';
          file.copySync(newPath);

          showMessage(context, 'ကူယူပြီးပါပြီ');

          //change pdf list ui
          pdfListNotifier.value = [];
          setState(() {
            isLoading = true;
          });
          //all fetch
          var pdfList =
              await getPdfList(sourcePath: currentNovelNotifier.value!.path);

          pdfListNotifier.value = pdfList;

          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        debugPrint(e.toString());
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
              //change pdf scanner ui
              final pdfScannerList = pdfScannerListNotifier.value
                  .where((pdf) => pdf.title != pdfFile.title)
                  .toList();
              pdfScannerListNotifier.value = pdfScannerList;
            }
          } catch (e) {
            debugPrint(e.toString());
          }
        },
      ),
    );
  }

  void pdfInfo(PdfFileModel pdf) {
    showDialogMessageWidget(
        context,
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${pdf.title}'),
                Text('Size: ${getParseFileSize(pdf.size.toDouble())}'),
                Text('Date: ${getParseDate(pdf.date)}'),
                Text('Path: ${pdf.path}'),
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text('PDF Scanner'),
      ),
      body: isLoading
          ? Center(child: TLoader())
          : PdfScannerPage(
              onClick: (_pdfFile) {
                pdfFile = _pdfFile;
                showMenu();
              },
            ),
    );
  }
}
