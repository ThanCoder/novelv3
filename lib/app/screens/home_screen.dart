import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/pages/home_page.dart';
import 'package:novel_v3/app/pages/novel_lib_page.dart';
import 'package:novel_v3/app/pages/novel_online_page.dart';
import 'package:novel_v3/app/pages/pdf_scanner_page.dart';
import 'package:novel_v3/app/pdf_readers/pdfrx_reader.dart';
import 'package:novel_v3/app/screens/novel_data_scanner_screen.dart';
import 'package:novel_v3/app/services/app_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: TabBarView(
          children: [
            const HomePage(),
            const NovelOnlinePage(),
            NovelLibPage(),
            const _PdfPage(),
            const NovelDataScannerScreen(),
          ],
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(
              text: 'Home',
              icon: Icon(Icons.home),
            ),
            Tab(
              text: 'Online',
              icon: Icon(Icons.cloud_download_outlined),
            ),
            Tab(
              text: 'Libary',
              icon: Icon(Icons.local_library_outlined),
            ),
            Tab(
              text: 'PDF Scanner',
              icon: Icon(Icons.picture_as_pdf),
            ),
            Tab(
              text: 'Restore Data',
              icon: Icon(Icons.restore),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfPage extends StatefulWidget {
  const _PdfPage({super.key});

  @override
  State<_PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<_PdfPage> {
  late PdfFileModel pdfFile;

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
              final pdfList = pdfScannerListNotifier.value
                  .where((pdf) => pdf.title != pdfFile.title)
                  .toList();
              pdfScannerListNotifier.value = pdfList;
            }
          } catch (e) {
            debugPrint(e.toString());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PdfScannerPage(
      onClick: (pdfFile) {
        pdfFile = pdfFile;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfrxReader(pdfFile: pdfFile),
          ),
        );
      },
      onLongClick: (_pdfFile) {
        pdfFile = _pdfFile;
        showMenu();
      },
    );
  }
}
