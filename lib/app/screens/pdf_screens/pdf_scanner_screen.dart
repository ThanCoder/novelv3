import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/pages/pdf_scanner_page.dart';
import 'package:novel_v3/app/pdf_readers/pdfrx_reader.dart';
import 'package:novel_v3/app/services/index.dart';

import '../../notifiers/novel_notifier.dart';
import '../../widgets/index.dart';

class PdfScannerScreen extends StatefulWidget {
  const PdfScannerScreen({super.key});

  @override
  State<PdfScannerScreen> createState() => _PdfScannerScreenState();
}

class _PdfScannerScreenState extends State<PdfScannerScreen> {
  void _showMenu(PdfFileModel pdfFile) {
    showModalBottomSheet(
      context: context,
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
          //delete
          ListTile(
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              deletePdf(pdfFile);
            },
            leading: const Icon(Icons.delete_forever),
            title: const Text('ဖျက်မယ် (Delete)'),
          ),
        ],
      ),
    );
  }

  void deletePdf(PdfFileModel pdfFile) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText:
            '`${pdfFile.title}` ဖျက်ချင်တာ သေချာပြီလား?\nပြန်ယူလို့ မရဘူးနော်!',
        cancelText: 'မလုပ်ဘူး',
        submitText: 'ဖျက်မယ်',
        onCancel: () {},
        onSubmit: () async {
          try {
            final file = File(pdfFile.path);
            if (file.existsSync()) {
              file.deleteSync();
            }
            //update ui
            final pdfList = pdfScannerListNotifier.value
                .where((pdf) => pdf.title != pdfFile.title)
                .toList();
            pdfScannerListNotifier.value = pdfList;
          } catch (e) {
            debugPrint(e.toString());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text('PDF Scanner'),
      ),
      body: PdfScannerPage(
        onClick: (pdfFile) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfrxReader(
                pdfFile: pdfFile,
                pdfConfig: PdfConfigModel(),
              ),
            ),
          );
        },
        onLongClick: _showMenu,
      ),
    );
  }
}
