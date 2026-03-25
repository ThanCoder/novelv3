import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/pdf_file.dart';
import 'package:novel_v3/core/services/pdf_services.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';

import 'package:t_widgets/t_widgets.dart';

class PdfListItem extends StatefulWidget {
  final PdfFile pdf;
  final void Function(PdfFile pdf)? onClicked;
  final void Function(PdfFile pdf)? onRightClicked;
  const PdfListItem({
    super.key,
    required this.pdf,
    this.onClicked,
    this.onRightClicked,
  });

  @override
  State<PdfListItem> createState() => _PdfListItemState();
}

class _PdfListItemState extends State<PdfListItem> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PdfListItem oldWidget) {
    if (oldWidget.pdf.path != widget.pdf.path) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  bool isLoading = false;
  Future<void> init() async {
    try {
      if (isLoading) return;
      if (cacheFile.existsSync()) return;

      setState(() {
        isLoading = true;
      });

      await PdfServices.instance.genPdfThumbnail(widget.pdf, cacheFile.path);

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('[PdfListItem:init]: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  File get cacheFile => File(
    PathUtil.getCachePath(
      name: 'cache-${widget.pdf.title.getName(withExt: false)}.png',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () => widget.onClicked?.call(widget.pdf),
      onLongPress: () => widget.onRightClicked?.call(widget.pdf),
      onSecondaryTap: () => widget.onRightClicked?.call(widget.pdf),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 5,
        children: [
          SizedBox(
            width: 110,
            height: 130,
            child: isLoading
                ? TLoader.random()
                : TImage(source: cacheFile.path),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                widget.pdf.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text('Size: ${widget.pdf.getSize.fileSizeLabel()}'),
            ],
          ),
        ],
      ),
    );
  }
}
