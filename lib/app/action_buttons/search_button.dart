import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/customs/novel_search.dart';
import 'package:novel_v3/app/riverpods/providers.dart';

import '../models/index.dart';

class SearchButton extends ConsumerWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context, ref) {
    List<NovelModel> list = ref.watch(novelNotifierProvider).list;
    return IconButton(
      onPressed: () {
        showSearch(
          context: context,
          delegate: NovelSearch(list: list, ref: ref),
        );
      },
      icon: const Icon(Icons.search),
    );
  }
}
