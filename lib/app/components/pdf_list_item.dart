import 'package:flutter/material.dart';
import 'package:novel_v3/app/extensions/datetime_extension.dart';
import 'package:novel_v3/app/extensions/double_extension.dart';
import 'package:novel_v3/app/models/pdf_model.dart';
import 'package:novel_v3/app/widgets/index.dart';

class PdfListItem extends StatelessWidget {
  PdfModel pdf;
  void Function(PdfModel pdf) onClicked;
  void Function(PdfModel pdf)? onLongClicked;
  PdfListItem({
    super.key,
    required this.pdf,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(pdf),
      onLongPress: () {
        if (onLongClicked != null) {
          onLongClicked!(pdf);
        }
      },
      onSecondaryTap: () {
        if (onLongClicked != null) {
          onLongClicked!(pdf);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          child: Row(
            spacing: 7,
            children: [
              SizedBox(
                width: 150,
                height: 160,
                child: Container(
                  color: Colors.black,
                  child: MyImageFile(path: pdf.coverPath),
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 2,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pdf.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(pdf.size.toDouble().toParseFileSize()),
                    Text(DateTime.fromMillisecondsSinceEpoch(pdf.date)
                        .toParseTime()),
                    Text(DateTime.fromMillisecondsSinceEpoch(pdf.date)
                        .toTimeAgo()),
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
