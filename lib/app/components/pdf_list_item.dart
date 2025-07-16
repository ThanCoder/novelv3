import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/pdf_model.dart';
import 'package:novel_v3/app/setting/app_notifier.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg/types/src_dist_type.dart';

class PdfListItem extends StatefulWidget {
  PdfModel pdf;
  void Function(PdfModel pdf) onClicked;
  void Function(PdfModel pdf)? onLongClicked;
  bool isShowPathLabel;
  PdfListItem({
    super.key,
    required this.pdf,
    required this.onClicked,
    this.onLongClicked,
    this.isShowPathLabel = false,
  });

  @override
  State<PdfListItem> createState() => _PdfListItemState();
}

class _PdfListItemState extends State<PdfListItem> {
  @override
  void initState() {
    super.initState();
    init();
  }

  bool isLoading = false;

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      // await Future.delayed(Duration(seconds: 3));

      //gen cover
      await ThanPkg.platform.genPdfThumbnail(
        pathList: [
          SrcDistType(
            src: widget.pdf.path,
            dist: widget.pdf.coverPath,
          ),
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
      onLongPress: () {
        if (widget.onLongClicked != null) {
          widget.onLongClicked!(widget.pdf);
        }
      },
      onSecondaryTap: () {
        if (widget.onLongClicked != null) {
          widget.onLongClicked!(widget.pdf);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 9,
              children: [
                 SizedBox(
                  width: 130,
                  height: 140,
                  child:isLoading ? TLoader(): Container(
                    color:
                        isDarkThemeNotifier.value ? Colors.white : Colors.black,
                    child: TImageFile(path: widget.pdf.coverPath),
                  ),
                ),
                // text content
                Expanded(
                  child: Column(
                    spacing: 2,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.pdf.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                          'Size: ${widget.pdf.size.toDouble().toFileSizeLabel()}'),
                      Text('Ago: ${widget.pdf.date.toTimeAgo()}'),
                      Text('Date: ${widget.pdf.date.toParseTime()}'),
                      widget.isShowPathLabel
                          ? Text(
                              'Path: ${widget.pdf.path}',
                              style: const TextStyle(fontSize: 12),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
