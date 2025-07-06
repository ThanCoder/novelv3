import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/author_wrap_view.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/route_helper.dart';

class SearchHome extends StatelessWidget {
  List<NovelModel> list;
  SearchHome({
    super.key,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    final authorList = list.map((nv) => nv.author).toSet().toList();
    final mcList = list.map((nv) => nv.mc).toSet().toList();
    // sort
    authorList.sort((a, b) => a.compareTo(b));
    mcList.sort((a, b) => a.compareTo(b));
    return Consumer(
      builder: (context, ref, child) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [
            // author
            SliverToBoxAdapter(
              child: AuthorWrapView(
                title: 'ရေးသားသူ',
                list: authorList,
                onClicked: (title) {
                  goSeeAllScreenWithAuthor(context, ref, title);
                },
              ),
            ),
            const SliverToBoxAdapter(child: Divider()),
            //mc
            SliverToBoxAdapter(
              child: AuthorWrapView(
                title: 'အထိက ဇောတ်ကောင်',
                list: mcList,
                onClicked: (title) {
                  goSeeAllScreenWithMC(context, ref, title);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
