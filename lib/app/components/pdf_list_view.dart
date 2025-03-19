import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/utils/app_util.dart';

import '../widgets/index.dart';

class PdfListView extends StatelessWidget {
  List<PdfFileModel> pdfList;
  void Function(PdfFileModel pdfFile)? onClick;
  void Function(PdfFileModel pdfFile)? onLongClick;
  ScrollController? controller;
  Color? activeColor;
  String activeTitle;

  PdfListView({
    super.key,
    required this.pdfList,
    this.onClick,
    this.onLongClick,
    this.controller,
    this.activeColor,
    this.activeTitle = '',
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemBuilder: (context, index) => _ListItem(
        activeColor: activeColor,
        activeTitle: activeTitle,
        pdfFile: pdfList[index],
        onClick: (pdfFile) {
          if (onClick != null) {
            onClick!(pdfFile);
          }
        },
        onLongClick: (pdfFile) {
          if (onLongClick != null) {
            onLongClick!(pdfFile);
          }
        },
      ),
      // separatorBuilder: (context, index) => const Divider(),
      itemCount: pdfList.length,
    );
  }
}

class _ListItem extends StatelessWidget {
  PdfFileModel pdfFile;
  void Function(PdfFileModel pdfFile) onClick;
  void Function(PdfFileModel pdfFile) onLongClick;
  Color? activeColor;
  String activeTitle;
  _ListItem({
    required this.pdfFile,
    required this.onClick,
    required this.onLongClick,
    this.activeColor,
    this.activeTitle = '',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClick(pdfFile),
      onLongPress: () => onLongClick(pdfFile),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          color: activeTitle == pdfFile.title ? Colors.teal[700] : null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 130,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                        color: Colors.white,
                        child: MyImageFile(path: pdfFile.coverPath)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pdfFile.title, maxLines: 2),
                      Text(AppUtil.instance.getParseFileSize(pdfFile.size.toDouble())),
                      Text(AppUtil.instance.getParseDate(pdfFile.date)),
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
