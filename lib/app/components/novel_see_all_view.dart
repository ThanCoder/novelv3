import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_grid_item.dart';
import 'package:novel_v3/app/models/index.dart';

class NovelSeeAllView extends StatelessWidget {
  List<NovelModel> list;
  String title;
  String moreTitle;
  int showCount;
  int? showLines;
  double fontSize;
  void Function(String title, List<NovelModel> list) onSeeAllClicked;
  void Function(NovelModel novel) onClicked;
  EdgeInsetsGeometry? margin;
  double padding;

  NovelSeeAllView(
      {super.key,
      required this.title,
      required this.list,
      required this.onSeeAllClicked,
      required this.onClicked,
      this.showCount = 8,
      this.margin,
      this.showLines,
      this.fontSize = 11,
      this.padding = 6,
      this.moreTitle = 'More'});

  @override
  Widget build(BuildContext context) {
    // print('${list.length} > $showCount');

    final showList = list.take(showCount).toList();
    if (showList.isEmpty) return const SizedBox.shrink();
    int _showLines = 1;
    if (showLines == null && showList.length > 1) {
      _showLines = 2;
    } else {
      _showLines = showLines ?? 1;
    }

    return Container(
      padding: EdgeInsets.all(padding),
      margin: margin,
      child: SizedBox(
        height: _showLines * 170,
        child: Column(
          spacing: 5,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),
                list.length > showCount
                    ? Container(
                        margin: const EdgeInsets.only(right: 5),
                        child: TextButton(
                          onPressed: () => onSeeAllClicked(title, list),
                          child: Text(
                            moreTitle,
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ))
                    : const SizedBox.shrink(),
              ],
            ),
            Expanded(
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: showList.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 170,
                  mainAxisExtent: 130,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                itemBuilder: (context, index) => NovelGridItem(
                  fontSize: fontSize,
                  novel: showList[index],
                  onClicked: onClicked,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
