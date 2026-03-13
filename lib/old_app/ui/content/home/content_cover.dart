// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';

class ContentCover extends SliverPersistentHeaderDelegate {
  final Novel novel;
  ContentCover({required this.novel});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Center(
      child: SizedBox(
        width: 170,
        height: 220,
        child: TImage(source: novel.getCoverPath),
      ),
    );
  }

  @override
  double get maxExtent => 290;

  @override
  double get minExtent => 200;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
