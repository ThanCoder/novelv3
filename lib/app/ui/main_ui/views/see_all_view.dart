import 'package:flutter/material.dart';

class SeeAllView<T> extends StatelessWidget {
  List<T> list;
  String title;
  String moreTitle;
  int showCount;
  double fontSize;
  double padding;
  EdgeInsetsGeometry? margin;
  Color? titleColor;
  void Function(String title, List<T> list) onSeeAllClicked;
  Widget Function(BuildContext context, T item) gridItemBuilder;
  double itemHeight;
  double itemWidth;
  bool showMoreButtonBottomPos;

  SeeAllView({
    super.key,
    required this.title,
    required this.list,
    required this.onSeeAllClicked,
    required this.gridItemBuilder,
    this.showCount = 4,
    this.margin,
    this.fontSize = 11,
    this.padding = 6,
    this.moreTitle = 'More',
    this.titleColor,
    this.itemHeight = 200,
    this.itemWidth = 160,
    this.showMoreButtonBottomPos = false,
  });

  @override
  Widget build(BuildContext context) {
    final showList = list.take(showCount).toList();
    if (showList.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        // header row
        _getHeader(),
        // grid item
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 5,
            children: List.generate(
              showList.length,
              (index) => MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox(
                    width: itemWidth,
                    height: itemHeight,
                    child: gridItemBuilder(context, showList[index])),
              ),
            ),
          ),
        ),
        // botton nav
        _getSeeAllButtonBottomPos(),
      ],
    );
  }

  Widget _getHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: titleColor)),
          _getSeeAllButton(),
        ],
      ),
    );
  }

  Widget _getSeeAllButtonBottomPos() {
    if (!showMoreButtonBottomPos) {
      return const SizedBox.shrink();
    }
    if (list.length > showCount) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: 15),
          TextButton(
              onPressed: () => onSeeAllClicked(title, list),
              child: Text(
                'See All',
                style: TextStyle(color: Colors.blue),
              ))
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _getSeeAllButton() {
    if (list.length > showCount) {
      return Container(
        margin: const EdgeInsets.only(right: 2),
        child: GestureDetector(
          onTap: () => onSeeAllClicked(title, list),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              spacing: 2,
              children: [
                Text(
                  moreTitle,
                  style: const TextStyle(color: Colors.blue),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                )
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
