import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/pdf_file.dart';
import 'package:novel_v3/app/others/pdf_scanner/pdf_scanner_screen.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/content/pdf_page/pdf_rc_bottom_sheet.dart';
import 'package:t_widgets/t_widgets.dart';

class PdfMenuBottonSheet extends StatefulWidget {
  final VoidCallback? onClosed;
  const PdfMenuBottonSheet({super.key, this.onClosed});

  @override
  State<PdfMenuBottonSheet> createState() => _PdfMenuBottonSheetState();
}

class _PdfMenuBottonSheetState extends State<PdfMenuBottonSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.add_circle_outline),
          title: Text('Add PDF'),
          onTap: _addPdfScanner,
        ),
      ],
    );
  }

  void _addPdfScanner() {
    goRoute(
      context,
      builder: (context) => PdfScannerScreen(
        isMultipleSelected: true,
        onChoosed: (ctx, files) {
          closeContext(ctx);
          _addPdfRCBottomSheet(files);
        },
      ),
    );
  }

  void _addPdfRCBottomSheet(List<PdfFile> files) {
    showTMenuBottomSheetSingle(
      context,
      child: PdfRcBottomSheet(
        files: files.map((e) => e.path).toList(),
        onClosed: () {
          widget.onClosed?.call();
        },
      ),
    );
  }
}
