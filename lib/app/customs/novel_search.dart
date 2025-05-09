import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/author_wrap_view.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/route_helper.dart';

import '../components/novel_grid_item.dart';

class NovelSearch extends SearchDelegate {
  List<NovelModel> list = [];
  WidgetRef ref;
  NovelSearch({
    required this.list,
    required this.ref,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      query.isNotEmpty
          ? IconButton(
              onPressed: () {
                query = '';
              },
              icon: const Icon(Icons.clear_all_rounded),
            )
          : const SizedBox(),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return _searchResult();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      return _searchResult();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          // author
          SliverToBoxAdapter(
            child: AuthorWrapView(
              title: 'Author',
              list: list.map((nv) => nv.author).toSet().toList(),
              onClicked: (title) {
                goSeeAllScreenWithAuthor(context, ref, title);
              },
            ),
          ),
          const SliverToBoxAdapter(child: Divider()),
          //mc
          SliverToBoxAdapter(
            child: AuthorWrapView(
              title: 'MC',
              list: list.map((nv) => nv.mc).toSet().toList(),
              onClicked: (title) {
                goSeeAllScreenWithMC(context, ref, title);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchResult() {
    if (query.isEmpty) {
      return const Center(child: Text('တစ်ခုခုရေးပါ'));
    }
    // filter
    final res = list.where((nv) {
      if (nv.title.toLowerCase().contains(query.toLowerCase())) {
        return true;
      }
      //mc
      if (nv.mc.toLowerCase().contains(query.toLowerCase())) {
        return true;
      }
      //author
      if (nv.author.toLowerCase().contains(query.toLowerCase())) {
        return true;
      }
      return false;
    }).toList();
    if (res.isEmpty) {
      return const Center(child: Text('မရှိပါ...'));
    }
    return GridView.builder(
      itemCount: res.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisExtent: 200,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemBuilder: (context, index) => NovelGridItem(
        novel: res[index],
        onClicked: (novel) {
          goNovelContentPage(context, ref, novel);
        },
      ),
    );
  }
}
