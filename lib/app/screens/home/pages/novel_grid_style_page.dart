import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/novel_grid_item.dart';
import 'package:novel_v3/app/extensions/novel_extension.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:t_widgets/t_widgets.dart';

class NovelGridStylePage extends ConsumerWidget {
  AppBar? appBar;
  NovelGridStylePage({
    super.key,
    this.appBar,
  });

  @override
  Widget build(BuildContext context, ref) {
    final pro = ref.watch(novelNotifierProvider);
    final isLoading = pro.isLoading;
    final list = pro.list;
    // sort
    list.sortDate(false);

    return Scaffold(
      appBar: appBar,
      body: isLoading
          ? Center(child: TLoaderRandom())
          : GridView.builder(
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
                  goNovelContentPage(context, ref, novel);
                },
                onLongClicked: (novel) {
                  goNovelEditForm(context, ref, novel);
                },
              ),
            ),
    );
  }
}
