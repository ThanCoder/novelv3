import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/novel.dart';

class NovelInfo extends StatelessWidget {
  final Novel novel;
  const NovelInfo({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Author: ${novel.meta.author}'),
            Text('MC: ${novel.meta.mc}'),
            Text('Translator: ${novel.meta.translator}'),
            _otherTitles(),
          ],
        ),
      ),
    );
  }

  Widget _otherTitles() {
    if (novel.meta.otherTitleList.isEmpty) {
      return SizedBox.shrink();
    }
    return Wrap(
      children: novel.meta.otherTitleList.map((e) => Text(e)).toList(),
    );
  }
}
