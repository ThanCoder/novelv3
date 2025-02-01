import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/pdf_bookmark_model.dart';

class PdfBookMarkListView extends StatelessWidget {
  List<PdfBookmarkModel> pdfBookList;
  void Function(PdfBookmarkModel pdfBookmark)? onClick;
  void Function(PdfBookmarkModel pdfBookmark)? onLongClick;
  PdfBookMarkListView({
    super.key,
    required this.pdfBookList,
    this.onClick,
    this.onLongClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => _ListItem(
        pdfBookmark: pdfBookList[index],
        onClick: (pdfBookmark) {
          if (onClick != null) {
            onClick!(pdfBookmark);
          }
        },
        onLongClick: (pdfBookmark) {
          if (onLongClick != null) {
            onLongClick!(pdfBookmark);
          }
        },
      ),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: pdfBookList.length,
    );
  }
}

class _ListItem extends StatelessWidget {
  PdfBookmarkModel pdfBookmark;
  void Function(PdfBookmarkModel pdfBookmark) onClick;
  void Function(PdfBookmarkModel pdfBookmark) onLongClick;
  _ListItem({
    super.key,
    required this.pdfBookmark,
    required this.onClick,
    required this.onLongClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClick(pdfBookmark),
      onLongPress: () => onLongClick(pdfBookmark),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            //chapter
            Text(
              pdfBookmark.pageIndex.toString(),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 10),
            //title
            Expanded(
              child: Text(
                pdfBookmark.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
