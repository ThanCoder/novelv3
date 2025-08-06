import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../types/pdf_config_model.dart';

class CustomPdfReaderScreen extends StatefulWidget {
  PdfConfigModel pdfConfig;
  String sourcePath;
  String title;
  void Function(PdfConfigModel pdfConfig)? onConfigSaved;
  String? bookmarkPath;
  CustomPdfReaderScreen({
    super.key,
    required this.pdfConfig,
    required this.sourcePath,
    this.onConfigSaved,
    this.title = 'PDF Reader',
    this.bookmarkPath,
  });

  @override
  State<CustomPdfReaderScreen> createState() => _CustomPdfReaderScreenState();
}

class _CustomPdfReaderScreenState extends State<CustomPdfReaderScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(widget.title),),body: _getCurrentPdfReader(),);
  }

  Widget _getPdfItem(PdfDocument? document) {
    return ListView.builder(
      itemCount: document?.pages.length ?? 0,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(8),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Expanded(
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
        useProgressiveLoading: true,
        builder: (context, document) => _getPdfItem(document),
      );
    } else {
      return PdfDocumentViewBuilder.file(
        widget.sourcePath,
        useProgressiveLoading: true,
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
}
