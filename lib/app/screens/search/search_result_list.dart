import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/novel_list_item.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/route_helper.dart';

class SearchResultList extends ConsumerWidget {
  List<NovelModel> list;
  SearchResultList({
    super.key,
    required this.list,
  });

  @override
  Widget build(BuildContext context, ref) {
    return ListView.separated(
      itemBuilder: (context, index) => NovelListItem(
        novel: list[index],
        onClicked: (novel) {
          goNovelContentPage(context, ref, novel);
        },
      ),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: list.length,
    );
  }
}
