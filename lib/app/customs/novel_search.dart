import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/author_wrap_view.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/route_helper.dart';

class NovelSearch extends SearchDelegate {
  List<NovelModel> novelList = [];
  NovelSearch({required this.novelList});

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
    if (query.isEmpty) {
      return const Center(child: Text('တစ်ခုခုရေးပါ'));
    }
    final res = novelList
        .where((nv) => nv.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final mcRes = novelList
        .where((nv) => nv.mc.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final authorRes = novelList
        .where((nv) => nv.author.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          //mc
          SliverToBoxAdapter(
            child:
                mcRes.isNotEmpty ? const Text('MC Result') : const SizedBox(),
          ),
          SliverList.separated(
            itemCount: mcRes.length,
            itemBuilder: (context, index) {
              final novel = mcRes[index];
              return ListTile(
                title: Text(novel.title),
                onTap: () => goNovelContentPage(context, novel),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          ),
          SliverToBoxAdapter(
            child: mcRes.isNotEmpty ? const Divider() : const SizedBox(),
          ),
          //author
          SliverToBoxAdapter(
            child: authorRes.isNotEmpty
                ? const Text('Author Result')
                : const SizedBox(),
          ),
          SliverList.separated(
            itemCount: authorRes.length,
            itemBuilder: (context, index) {
              final novel = authorRes[index];
              return ListTile(
                title: Text(novel.title),
                onTap: () => goNovelContentPage(context, novel),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          ),

          SliverToBoxAdapter(
            child: authorRes.isNotEmpty ? const Divider() : const SizedBox(),
          ),

          //novel
          SliverToBoxAdapter(
            child:
                res.isNotEmpty ? const Text('Novel Result') : const SizedBox(),
          ),
          SliverList.separated(
            itemCount: res.length,
            itemBuilder: (context, index) {
              final novel = res[index];
              return ListTile(
                title: Text(novel.title),
                onTap: () => goNovelContentPage(context, novel),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          // author
          SliverToBoxAdapter(
            child: AuthorWrapView(
              title: 'Author',
              list: novelList.map((nv) => nv.author).toSet().toList(),
              onClicked: (title) {
                goSeeAllScreenWithAuthor(context, title);
              },
            ),
          ),
          const SliverToBoxAdapter(child: Divider()),
          //mc
          SliverToBoxAdapter(
            child: AuthorWrapView(
              title: 'MC',
              list: novelList.map((nv) => nv.mc).toSet().toList(),
              onClicked: (title) {
                goSeeAllScreenWithMC(context, title);
              },
            ),
          ),
        ],
      ),
    );
  }
}
