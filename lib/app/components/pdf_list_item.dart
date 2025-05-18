import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/pdf_model.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 7,
              children: [
                SizedBox(
                  width: 130,
                  height: 140,
                  child: Container(
                    color:
                        isDarkThemeNotifier.value ? Colors.white : Colors.black,
                    child: TImageFile(path: pdf.coverPath),
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
                      Text('Size: ${pdf.size.toDouble().toFileSizeLabel()}'),
                      Text(
                          'Date: ${DateTime.fromMillisecondsSinceEpoch(pdf.date).toAutoParseTime()}'),
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
      ),
    );
  }
}
