import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/chapter_model.dart';

class ChapterListView extends StatelessWidget {
  List<ChapterModel> chapterList;
  void Function(ChapterModel chapter)? onClick;
  void Function(ChapterModel chapter)? onLongClick;
  ScrollController? controller;
  bool isSelected;
  String selectedTitle;
  ChapterListView({
    super.key,
    required this.chapterList,
    this.onClick,
    this.onLongClick,
    this.isSelected = false,
    this.selectedTitle = '',
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      separatorBuilder: (context, index) => const Divider(),
      itemCount: chapterList.length,
      itemBuilder: (context, index) => _ListItem(
        chapter: chapterList[index],
        isSelected: isSelected,
        selectedTitle: selectedTitle,
        onClick: (chapter) {
          if (onClick != null) {
            onClick!(chapter);
          }
        },
        onLongClick: (chapter) {
          if (onLongClick != null) {
            onLongClick!(chapter);
          }
        },
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  ChapterModel chapter;
  double fontSize;
  bool isSelected;
  String selectedTitle;
  void Function(ChapterModel chapter) onClick;
  void Function(ChapterModel chapter) onLongClick;
  _ListItem({
    required this.chapter,
    required this.onClick,
    required this.onLongClick,
    this.fontSize = 16,
    this.isSelected = false,
    this.selectedTitle = '',
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onClick(chapter),
      onLongPress: () => onLongClick(chapter),
      title: Row(
        children: [
          Text(
            'Chapter ',
            style: TextStyle(
              fontSize: fontSize,
              color: isSelected
                  ? selectedTitle == chapter.title
                      ? Colors.teal
                      : null
                  : null,
            ),
          ),
          Text(
            chapter.title,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontSize: fontSize,
              color: isSelected
                  ? selectedTitle == chapter.title
                      ? Colors.teal
                      : null
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
