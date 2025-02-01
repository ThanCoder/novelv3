import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/custom_class/novel_search_delegate.dart';
import 'package:novel_v3/app/dialogs/add_new_novel_dialog.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/drawers/home_drawer.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/pages/home_page.dart';
import 'package:novel_v3/app/pages/novel_lib_page.dart';
import 'package:novel_v3/app/pages/pdf_scanner_page.dart';
import 'package:novel_v3/app/pdf_readers/pdfrx_reader.dart';
import 'package:novel_v3/app/screens/novel_data_scanner_screen.dart';
import 'package:novel_v3/app/services/app_services.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //menu
  void showBottomMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {},
        builder: (context) => SizedBox(
          height: 250,
          child: ListView(
            children: [
              //add new novel
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        AddNewNovelDialog(dialogContext: context),
                  );
                },
                leading: const Icon(Icons.add),
                title: const Text('Add New Novel'),
              ),
              //add new novel from data
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NovelDataScannerScreen(),
                    ),
                  );
                  // showDialog(
                  //   context: context,
                  //   builder: (context) => ImportNovelDataDialog(
                  //     dialogContext: context,
                  //     dataFilePath:
                  //         '/home/thancoder/Downloads/ငါ့မှာအပတ်တိုင်းအလုပ်သစ်ရှိတယ်.npz',
                  //   ),
                  // );
                },
                leading: const Icon(Icons.add),
                title: const Text('Add Novel Data File'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchBar() {
    showSearch(
      context: context,
      delegate: NovelSearchDelegate(novelList: novelListNotifier.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text(appTitle),
        actions: [
          //search
          IconButton(
            onPressed: () {
              _showSearchBar();
            },
            icon: const Icon(Icons.search),
          ),
          //more
          IconButton(
            onPressed: () {
              showBottomMenu();
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      drawer: const HomeDrawer(),
      body: const _Tab(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     try {
      //       // final res =
      //       //     await
      //       // print(res);
      //     } catch (e) {
      //       debugPrint(e.toString());
      //     }
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 4,
      child: Scaffold(
        body: TabBarView(
          children: [
            HomePage(),
            NovelLibPage(),
            _PdfPage(),
            NovelDataScannerScreen(),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(
              text: 'Home',
              icon: Icon(Icons.home),
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
