import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:novel_v3/app/ui/components/list_row_item.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg/types/src_dest_type.dart';
import '../novel_dir_app.dart';

class PdfListItem extends StatefulWidget {
  final NovelPdf pdf;
  final String? cachePath;
  final bool isEnableRecent;
  final void Function(NovelPdf pdf) onClicked;
  final void Function(NovelPdf pdf)? onRightClicked;
  const PdfListItem({
    super.key,
    required this.pdf,
    required this.onClicked,
    this.onRightClicked,
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
      NovelDirApp.showDebugLog(e.toString(), tag: 'PdfListItem:init');
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
              color:
                  widget.isEnableRecent &&
                      PdfServices.isExistsRecent(
                        novelId: widget.pdf.getParentPath.getName(),
                        pdfName: widget.pdf.getTitle,
                      )
                  ? const Color.fromARGB(181, 42, 170, 157)
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
                              color: Setting.getAppConfig.isDarkMode
                                  ? Colors.white
                                  : null,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TImage(source: widget.pdf.getCoverPath),
                          ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        ListRowItem(
                          text: widget.pdf.getTitle,
                          iconData: Icons.title,
                          fontWeight: FontWeight.bold,
                        ),
                        ListRowItem(
                          text: widget.pdf.getSize,
                          iconData: Icons.sd_storage,
                        ),
                        ListRowItem(
                          text: widget.pdf.getDate.toParseTime(),
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
