import 'package:flutter/material.dart';

import '../novel_dir_db.dart';

ValueNotifier<List<Novel>> novelSeeAllScreenNotifier = ValueNotifier([]);

class NovelSeeAllScreen extends StatelessWidget {
  String title;
  NovelSeeAllScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ValueListenableBuilder(
          valueListenable: novelSeeAllScreenNotifier,
          builder: (context, list, child) {
            return GridView.builder(
              itemCount: list.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisExtent: 200,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemBuilder: (context, index) => NovelGridItem(
                novel: list[index],
                onClicked: (novel) => goContentScreen(context, novel),
              ),
            );
          }),
    );
  }
}
