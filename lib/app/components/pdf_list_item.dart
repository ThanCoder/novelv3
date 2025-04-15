import 'package:flutter/material.dart';
import 'package:novel_v3/app/extensions/datetime_extension.dart';
import 'package:novel_v3/app/extensions/double_extension.dart';
import 'package:novel_v3/app/models/pdf_model.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/widgets/index.dart';

class PdfListItem extends StatelessWidget {
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
                width: 130,
                height: 140,
                child: Container(
                  color:
                      isDarkThemeNotifier.value ? Colors.white : Colors.black,
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
                    Text('Size: ${pdf.size.toDouble().toParseFileSize()}'),
                    Text(
                        'Date: ${DateTime.fromMillisecondsSinceEpoch(pdf.date).toParseTime()}'),
                    Text(
                        'Ago: ${DateTime.fromMillisecondsSinceEpoch(pdf.date).toTimeAgo()}'),
                    isShowPathLabel
                        ? Text(
                            'Path: ${pdf.path}',
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
    );
  }
}
