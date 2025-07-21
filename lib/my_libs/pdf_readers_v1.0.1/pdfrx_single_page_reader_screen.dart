import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import 'pdf_config_model.dart';

class PdfrxSinglePageReaderScreen extends StatefulWidget {
  PdfConfigModel pdfConfig;
  String sourcePath;
  String title;
  void Function(PdfConfigModel pdfConfig)? saveConfig;
  String? bookmarkPath;
  PdfrxSinglePageReaderScreen({
    super.key,
    required this.pdfConfig,
    required this.sourcePath,
    this.saveConfig,
    this.title = 'PDF Reader',
    this.bookmarkPath,
  });

  @override
  State<PdfrxSinglePageReaderScreen> createState() =>
      _PdfrxSinglePageReaderScreenState();
}

class _PdfrxSinglePageReaderScreenState
    extends State<PdfrxSinglePageReaderScreen> {
  late PdfConfigModel config;

  @override
  void initState() {
    config = widget.pdfConfig;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _getPdfItem(PdfDocument? document) {
    return ListView.builder(
      itemCount: document?.pages.length ?? 0,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(8),
          height: 240,
          child: Column(
            children: [
              SizedBox(
                height: 220,
                child: PdfPageView(
                  document: document,
                  pageNumber: index + 1,
                  alignment: Alignment.center,
                ),
              ),
              Text(
                '${index + 1}',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getCurrentPdfReader() {
    if (widget.sourcePath.isEmpty) return const SizedBox.shrink();
    if (widget.sourcePath.startsWith('http')) {
      //is online
      return PdfDocumentViewBuilder.uri(
        Uri.parse(widget.sourcePath),
        builder: (context, document) => _getPdfItem(document),
      );
    } else {
      return PdfDocumentViewBuilder.file(
        widget.sourcePath,
        builder: (context, document) => _getPdfItem(document),
      );
    }
  }

  Widget _getColorFilteredPdfReader() {
    return Column(
      children: [
        // SizedBox(height: isFullScreen ? 0 : 40),
        Expanded(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.white,
              config.isDarkMode ? BlendMode.difference : BlendMode.dst,
            ),
            child: _getCurrentPdfReader(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getCurrentPdfReader();
  }
}
