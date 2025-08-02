import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/novel_list_item.dart';
import 'package:novel_v3/app/extensions/novel_extension.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:t_widgets/t_widgets.dart';

class NovelListStylePage extends ConsumerWidget {
  AppBar? appBar;
  NovelListStylePage({super.key, this.appBar});

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
          : ListView.separated(
              itemBuilder: (context, index) => NovelListItem(
                novel: list[index],
                onClicked: (novel) => goNovelContentPage(context, ref, novel),
              ),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: list.length,
            ),
    );
  }
}
