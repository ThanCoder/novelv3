import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/pdf_file.dart';
import 'package:novel_v3/app/ui/components/pdf_cover_thumbnail_image.dart';
import 'package:than_pkg/than_pkg.dart';

class PdfFileListItem extends StatelessWidget {
  final PdfFile pdf;
  final Color? cardColor;
  final void Function(PdfFile pdf)? onClicked;
  final void Function(PdfFile pdf)? onRightClicked;
  const PdfFileListItem({
    super.key,
    required this.pdf,
    this.cardColor,
    this.onClicked,
    this.onRightClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked?.call(pdf),
      onLongPress: () => onRightClicked?.call(pdf),
      onSecondaryTap: () => onRightClicked?.call(pdf),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          color: cardColor,
          child: Row(
            spacing: 4,
            children: [
              SizedBox(
                width: 100,
                height: 120,
                child: PdfCoverThumbnailImage(
                  pdfFile: pdf,
                  savePath: pdf.getCoverPath,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.title),
                        Expanded(
                          child: Text(
                            pdf.title,
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.sd_card),
                        Expanded(child: Text(pdf.getSize.toFileSizeLabel())),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.date_range),
                        Expanded(child: Text(pdf.date.toParseTime())),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
