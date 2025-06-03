import 'package:flutter/material.dart';
import 'package:novel_v3/my_libs/share/novel_online_grid_item.dart';

import '../../app/components/author_wrap_view.dart';
import '../../app/models/novel_model.dart';
import 'share_novel_content_screen.dart';

class ShareSearchDelegate extends SearchDelegate {
  String url;
  List<NovelModel> list;
  ShareSearchDelegate({
    required this.url,
    required this.list,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [];
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
                final res = list.where((nv) => nv.author == title).toList();
                final novel = res.first;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ShareNovelContentScreen(url: url, novel: novel),
                  ),
                );
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
                final res = list.where((nv) => nv.mc == title).toList();
                final novel = res.first;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ShareNovelContentScreen(url: url, novel: novel),
                  ),
                );
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
      itemBuilder: (context, index) {
        final novel = res[index];
        return NovelOnlineGridItem(
          url: url,
          novel: novel,
          onClicked: (novel) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ShareNovelContentScreen(url: url, novel: novel),
              ),
            );
          },
        );
      },
    );
  }
}
