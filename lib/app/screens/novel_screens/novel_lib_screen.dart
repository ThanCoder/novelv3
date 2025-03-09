import 'package:flutter/material.dart';
import 'package:novel_v3/app/enums/book_mark_sort_name.dart';
import 'package:novel_v3/app/pages/home/novel_lib_page.dart';

class NovelLibScreen extends StatelessWidget {
  BookMarkSortName bookMarkSortName;
  NovelLibScreen({
    super.key,
    this.bookMarkSortName = BookMarkSortName.novelBookMark,
  });

  @override
  Widget build(BuildContext context) {
    return NovelLibPage(
      bookMarkSortName: bookMarkSortName,
    );
  }
}
