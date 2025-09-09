import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg/types/src_dest_type.dart';
import '../novel_dir_app.dart';

class PdfListItem extends StatefulWidget {
  NovelPdf pdf;
  String? cachePath;
  void Function(NovelPdf pdf) onClicked;
  void Function(NovelPdf pdf)? onRightClicked;
  PdfListItem({
    super.key,
    required this.pdf,
    required this.onClicked,
    this.onRightClicked,
    this.cachePath,
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
              child: Row(
                spacing: 8,
                children: [
                  SizedBox(
                    width: 140,
                    height: 150,
                    child: isLoading
                        ? TLoaderRandom()
                        : Container(
                            decoration: BoxDecoration(
                              color: Setting.getAppConfig.isDarkTheme
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
                        Text(
                          'T: ${widget.pdf.getTitle}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13),
                        ),
                        Text('Size: ${widget.pdf.getSize}'),
                        Row(
                          children: [
                            Icon(Icons.date_range),
                            Text(widget.pdf.getDate.toParseTime()),
                          ],
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
