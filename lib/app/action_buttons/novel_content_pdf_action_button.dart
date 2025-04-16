import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/dialogs/mediafire_downloader_dialog.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/provider/pdf_provider.dart';
import 'package:novel_v3/app/screens/pdf_scanner_screen.dart';
import 'package:provider/provider.dart';

class NovelContentPdfActionButton extends StatefulWidget {
  VoidCallback? onBackpress;
  NovelContentPdfActionButton({super.key, this.onBackpress});

  @override
  State<NovelContentPdfActionButton> createState() =>
      _NovelContentPdfActionButtonState();
}

class _NovelContentPdfActionButtonState
    extends State<NovelContentPdfActionButton> {
  void _downloadPdf() {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    showDialog(
      context: context,
      builder: (context) => MediafireDownloaderDialog(
        saveDirPath: novel.path,
        onError: (msg) {
          showDialogMessage(context, msg);
        },
        onSuccess: (filePath) {
          context.read<PdfProvider>().initList(novelPath: novel.path);
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
              // ListTile(
              //   leading: const Icon(Icons.download),
              //   title: const Text('Download PDF'),
              //   onTap: () {
              //     Navigator.pop(context);
              //     _downloadPdf();
              //   },
              // ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _addPdfFromScanner();
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
