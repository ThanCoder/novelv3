import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/pdf_config_model.dart';
import 'package:novel_v3/app/pages/pdf_scanner_page.dart';
import 'package:novel_v3/app/pdf_readers/pdfrx_reader.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';

class PdfScannerScreen extends StatelessWidget {
  const PdfScannerScreen({super.key});

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
      ),
    );
  }
}
