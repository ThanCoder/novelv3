import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:t_widgets/widgets/t_loader.dart';

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

  bool isLoading = false;
  PdfDocument? document;

  @override
  void initState() {
    config = widget.pdfConfig;
    init();
    super.initState();
  }

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      document = await _getPdfDocument();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _getPdfItem() {
    if (document == null) {
      return const Center(child: Text('pdf document is null!'));
    }
    // final page = document.pages[config.page - 1];
    print(config.page);
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(8),
          // height: page.height,
          // width: page.width,
          child: PdfPageView(
            document: document,
            pageNumber: config.page,
            alignment: Alignment.center,
          ),
        ),

        // nav
        Positioned(
          right: 10,
          bottom: 10,
          child: IconButton(
            onPressed: () {
              config.page = config.page + 1;
              setState(() {});
            },
            icon: const Icon(Icons.arrow_forward),
          ),
        ),
      ],
    );
  }

  Future<PdfDocument> _getPdfDocument() async {
    if (widget.sourcePath.startsWith('http')) {
      //is online
      return await PdfDocument.openUri(Uri.parse(widget.sourcePath));
    } else {
      return await PdfDocument.openFile(widget.sourcePath);
    }
  }

  Widget _getCurrentPdfReader() {
    if (widget.sourcePath.isEmpty) return const SizedBox.shrink();
    if (isLoading) return TLoader();
    return _getPdfItem();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _getCurrentPdfReader(),
    );
  }
}
