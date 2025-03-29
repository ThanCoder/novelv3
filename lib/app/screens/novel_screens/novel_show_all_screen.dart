import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_grid_item.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/screens/novel_screens/novel_content_screen.dart';
import 'package:novel_v3/app/widgets/index.dart';

class NovelShowAllScreen extends StatelessWidget {
  String title;
  List<NovelModel> list;
  NovelShowAllScreen({super.key, required this.title, required this.list});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 2,
      appBar: AppBar(
        title: Text(title),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisExtent: 200,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) => NovelGridItem(
          novel: list[index],
          onClick: (novel) {
            currentNovelNotifier.value = novel;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NovelContentScreen(novel: novel),
              ),
            );
          },
        ),
      ),
    );
  }
}
