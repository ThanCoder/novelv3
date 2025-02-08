import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/pdf_bookmark_model.dart';

class PdfBookMarkListView extends StatelessWidget {
  List<PdfBookmarkModel> pdfBookList;
  void Function(PdfBookmarkModel pdfBookmark) onClick;
  void Function(PdfBookmarkModel pdfBookmark)? onLongClick;
  void Function(PdfBookmarkModel pdfBookmark)? onDeleted;
  PdfBookMarkListView({
    super.key,
    required this.pdfBookList,
    required this.onClick,
    this.onLongClick,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => _ListItem(
        pdfBookmark: pdfBookList[index],
        onClick: (pdfBookmark) {
          onClick(pdfBookmark);
        },
        onLongClick: (pdfBookmark) {
          if (onLongClick != null) {
            onLongClick!(pdfBookmark);
          }
        },
        onDeleted: (PdfBookmarkModel pdfBookmark) {
          if (onDeleted != null) {
            onDeleted!(pdfBookmark);
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
  void Function(PdfBookmarkModel pdfBookmark) onDeleted;
  _ListItem({
    super.key,
    required this.pdfBookmark,
    required this.onClick,
    required this.onLongClick,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClick(pdfBookmark),
      onLongPress: () => onLongClick(pdfBookmark),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 10,
          children: [
            //chapter
            Text(
              pdfBookmark.pageIndex.toString(),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            //title
            Expanded(
              child: Text(
                pdfBookmark.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            IconButton(
              color: Colors.red,
              onPressed: () => onDeleted(pdfBookmark),
              icon: const Icon(Icons.delete_forever),
            ),
          ],
        ),
      ),
    );
  }
}
