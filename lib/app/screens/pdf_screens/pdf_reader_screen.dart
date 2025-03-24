import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/pdf_readers/pdf_config_model.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/pdf_readers/pdfrx_reader.dart';

class PdfReaderScreen extends StatefulWidget {
  PdfFileModel pdfFile;
  PdfReaderScreen({super.key, required this.pdfFile});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  Widget getCurrentWidget() {
    if (Platform.isAndroid || Platform.isLinux) {
      //get pdf config
      final pdfConfig = PdfConfigModel.fromPath(widget.pdfFile.configPath);
      return PdfrxReader(
        title: widget.pdfFile.title,
        sourcePath: widget.pdfFile.path,
        pdfConfig: pdfConfig,
        saveConfig: (pdfConfig) {
          try {
            pdfConfig.saveConfig(widget.pdfFile.configPath);
          } catch (e) {
            debugPrint('PdfrxReader->saveConfig: ${e.toString()}');
          }
        },
      );
    } else {
      return Center(
        child: Text('${Platform.operatingSystem} အတွက် pdf reader မရှိသေးပါ'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return getCurrentWidget();
  }
}
