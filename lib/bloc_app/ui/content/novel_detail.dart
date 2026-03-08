import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/novel.dart';

class NovelDetail extends StatelessWidget {
  final Novel novel;
  const NovelDetail({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SelectableText(novel.meta.desc),
    );
  }
}
