import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:novel_v3/core/models/pdf_file.dart';
import 'package:novel_v3/app/others/pdf_scanner/list_row_item.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg/types/src_dest_type.dart';

class PdfListItem extends StatefulWidget {
  final PdfFile pdf;
  final String? cachePath;
  final bool isEnableRecent;
  final void Function(PdfFile pdf) onClicked;
  final void Function(PdfFile pdf)? onRightClicked;
  final bool Function(PdfFile pdf)? onExists;
  const PdfListItem({
    super.key,
    required this.pdf,
    required this.onClicked,
    this.onRightClicked,
    this.onExists,
    this.cachePath,
    this.isEnableRecent = false,
  });

  @override
  State<PdfListItem> createState() => _PdfListItemState();
}

class _PdfListItemState extends State<PdfListItem> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => init());
    init();
  }

  @override
  void didUpdateWidget(covariant PdfListItem oldWidget) {
    if (oldWidget.pdf.path != widget.pdf.path) {
      init();
    }
    super.didUpdateWidget(oldWidget);
  }

  bool isLoading = false;

  Future<void> init() async {
    try {
      await Future.delayed(Duration(milliseconds: 500));

      if (File(widget.pdf.getCoverPath).existsSync()) return;
      setState(() {
        isLoading = true;
      });
      await ThanPkg.platform.genPdfThumbnail(
        pathList: [
          SrcDestType(src: widget.pdf.path, dest: widget.pdf.getCoverPath),
        ],
      );
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onClicked(widget.pdf),
      onSecondaryTap: () {
        if (widget.onRightClicked == null) return;
        widget.onRightClicked!(widget.pdf);
      },
      onLongPress: () {
        if (widget.onRightClicked == null) return;
        widget.onRightClicked!(widget.pdf);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child:
            Card(
              color: (widget.onExists?.call(widget.pdf) ?? false)
                  ? const Color.fromARGB(64, 23, 96, 155)
                  : null,
              child: Row(
                spacing: 8,
                children: [
                  SizedBox(
                    width: 110,
                    height: 130,
                    child: isLoading
                        ? TLoaderRandom()
                        : Container(
                            decoration: BoxDecoration(
                              color: Setting.getAppConfig.isDarkTheme
                                  ? Colors.white
                                  : null,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TImageFile(
                              path: widget.pdf.getCoverPath,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('[PdfListItem:TImageFile]: $error');
                                final file = File(widget.pdf.getCoverPath);
                                if (file.existsSync()) {
                                  file.deleteSync();
                                }
                                return TImage(source: '');
                              },
                            ),
                          ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        ListRowItem(
                          text: widget.pdf.title,
                          iconData: Icons.title,
                          fontWeight: FontWeight.bold,
                        ),
                        ListRowItem(
                          text: widget.pdf.getSize.toFileSizeLabel(),
                          iconData: Icons.sd_storage,
                        ),
                        ListRowItem(
                          text: widget.pdf.date.toParseTime(),
                          iconData: Icons.date_range,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().shimmer(
              delay: Duration(milliseconds: 500),
              duration: Duration(milliseconds: 700),
            ),
      ),
    );
  }
}
