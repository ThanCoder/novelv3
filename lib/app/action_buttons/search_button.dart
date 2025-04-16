import 'package:flutter/material.dart';
import 'package:novel_v3/app/customs/novel_search.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:provider/provider.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final list = context.watch<NovelProvider>().getList;
    return IconButton(
      onPressed: () {
        showSearch(
          context: context,
          delegate: NovelSearch(novelList: list),
        );
      },
      icon: const Icon(Icons.search),
    );
  }
}
