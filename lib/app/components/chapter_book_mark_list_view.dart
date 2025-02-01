import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/chapter_book_mark_model.dart';

class ChapterBookMarkListView extends StatelessWidget {
  List<ChapterBookMarkModel> bookList;
  void Function(ChapterBookMarkModel bookMark)? onClick;
  void Function(ChapterBookMarkModel bookMark)? onLongClick;
  ScrollController? controller;
  ChapterBookMarkListView({
    super.key,
    required this.bookList,
    this.onClick,
    this.onLongClick,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      separatorBuilder: (context, index) => const Divider(),
      itemCount: bookList.length,
      itemBuilder: (context, index) => _ListItem(
        bookMark: bookList[index],
        onClick: (bookMark) {
          if (onClick != null) {
            onClick!(bookMark);
          }
        },
        onLongClick: (bookMark) {
          if (onLongClick != null) {
            onLongClick!(bookMark);
          }
        },
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  ChapterBookMarkModel bookMark;
  double fontSize;
  void Function(ChapterBookMarkModel bookMark) onClick;
  void Function(ChapterBookMarkModel bookMark) onLongClick;
  _ListItem({
    required this.bookMark,
    required this.onClick,
    required this.onLongClick,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onClick(bookMark),
      onLongPress: () => onLongClick(bookMark),
      leading: Text(
        bookMark.chapter,
        style: TextStyle(
          fontSize: fontSize,
        ),
      ),
      title: Text(
        bookMark.title,
        style: TextStyle(
          fontSize: fontSize,
        ),
      ),
    );
  }
}
