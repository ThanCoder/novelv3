import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_grid_item.dart';
import 'package:novel_v3/app/models/index.dart';

class NovelSeeAllView extends StatelessWidget {
  List<NovelModel> list;
  String title;
  int showCount;
  void Function(String title, List<NovelModel> list) onSeeAllClicked;
  void Function(NovelModel novel) onClicked;
  EdgeInsetsGeometry? margin;

  NovelSeeAllView({
    super.key,
    required this.title,
    required this.list,
    required this.onSeeAllClicked,
    required this.onClicked,
    this.showCount = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final showList = list.take(showCount).toList();
    return Container(
      margin: margin,
      child: SizedBox(
        height: 270,
        child: Column(
          spacing: 5,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),
                GestureDetector(
                  onTap: () => onSeeAllClicked(title, list),
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'See All',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: showList.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
                  mainAxisExtent: 130,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                ),
                itemBuilder: (context, index) => NovelGridItem(
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
