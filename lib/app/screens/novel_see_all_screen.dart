import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_grid_item.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/widgets/core/my_scaffold.dart';

class NovelSeeAllScreen extends StatelessWidget {
  String title;
  List<NovelModel> list;
  NovelSeeAllScreen({super.key, required this.title, required this.list});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GridView.builder(
        itemCount: list.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisExtent: 200,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemBuilder: (context, index) => NovelGridItem(
          novel: list[index],
          onClicked: (novel) {
            goNovelContentPage(context, novel);
          },
        ),
      ),
    );
  }
}
