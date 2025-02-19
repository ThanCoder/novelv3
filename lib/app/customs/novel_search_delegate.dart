import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_list_view.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/screens/novel_content_screen.dart';

class NovelSearchDelegate extends SearchDelegate<NovelModel> {
  final List<NovelModel> novelList;
  bool isOnlineCover;
  void Function(NovelModel novel)? onClick;

  NovelSearchDelegate({
    required this.novelList,
    this.isOnlineCover = false,
    this.onClick,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      query.isNotEmpty
          ? IconButton(
              onPressed: () {
                query = '';
              },
              icon: const Icon(Icons.clear),
            )
          : Container(),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) return Container();
    final result = novelList
        .where((nv) => nv.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return NovelListView(
      novelList: result,
      isOnlineCover: isOnlineCover,
      onClick: (novel) {
        if (onClick != null) {
          onClick!(novel);
        } else {
          _onClick(context, novel);
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return Container();
    final result = novelList
        .where((nv) => nv.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return NovelListView(
      novelList: result,
      isOnlineCover: isOnlineCover,
      onClick: (novel) {
        if (onClick != null) {
          onClick!(novel);
        } else {
          _onClick(context, novel);
        }
      },
    );
  }

  void _onClick(BuildContext context, NovelModel novel) {
    currentNovelNotifier.value = novel;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelContentScreen(novel: novel),
      ),
    );
  }
}
