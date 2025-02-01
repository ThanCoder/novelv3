import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/pdf_book_mark_list_view.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/dialogs/rename_dialog.dart';
import 'package:novel_v3/app/models/pdf_bookmark_model.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/utils/pdf_bookmark_util.dart';

class PdfBookMarkListDrawer extends StatefulWidget {
  PdfFileModel pdfFile;
  int currentPage;
  void Function(int pageIndex)? onClick;
  PdfBookMarkListDrawer({
    super.key,
    required this.pdfFile,
    this.currentPage = 0,
    this.onClick,
  });

  @override
  State<PdfBookMarkListDrawer> createState() => _PdfBookMarkListDrawerState();
}

class _PdfBookMarkListDrawerState extends State<PdfBookMarkListDrawer> {
  @override
  void initState() {
    init();
    super.initState();
  }

  List<PdfBookmarkModel> bookList = [];

  void init() {
    try {
      setState(() {
        bookList =
            PdfBookmarkModel.getListFromPath(widget.pdfFile.bookMarkPath);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _showRemoveDialog(int pageIndex) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmDialog(
        dialogContext: context,
        contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
        cancelText: 'မလုပ်ဘူး',
        submitText: 'ဖျက်မယ်',
        onCancel: () {},
        onSubmit: () {
          removePdfBookmarkList(
              bookmarkPath: widget.pdfFile.bookMarkPath, pageIndex: pageIndex);
        },
      ),
    );
  }

  void _addBookMark() {
    showDialog(
      context: context,
      builder: (context) => RenameDialog(
        dialogContext: context,
        renameText: 'Untitled',
        renameLabelText: const Text('Book Mark Title'),
        onCancel: () {},
        onSubmit: (text) {
          addPdfBookmarkList(
            bookmarkPath: widget.pdfFile.bookMarkPath,
            pageIndex: widget.currentPage,
            title: text,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth < 400 ? screenWidth * 0.85 : screenWidth * 0.7,
      child: Drawer(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('PDF BookMark'),
            ),
            const Divider(),
            //form
            Wrap(
              children: [
                //quit add
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    addPdfBookmarkList(
                      bookmarkPath: widget.pdfFile.bookMarkPath,
                      pageIndex: widget.currentPage,
                    );
                    init();
                  },
                  child: const Column(
                    children: [Icon(Icons.bookmark_add), Text('Quit Add')],
                  ),
                ),
                //quit add
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _addBookMark();
                  },
                  child: const Column(
                    children: [Icon(Icons.bookmark_add), Text('Add')],
                  ),
                ),
              ],
            ),

            const Divider(),
            //list
            Expanded(
              child: PdfBookMarkListView(
                pdfBookList: bookList,
                onClick: (pdfBookmark) {
                  if (widget.onClick != null) {
                    widget.onClick!(pdfBookmark.pageIndex);
                    Navigator.pop(context);
                  }
                },
                onLongClick: (pdfBookmark) {
                  Navigator.pop(context);
                  _showRemoveDialog(pdfBookmark.pageIndex);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
