import 'package:flutter/material.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';

class NovelOnlinePage extends StatelessWidget {
  const NovelOnlinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Online'),
      ),
      body: Placeholder(),
    );
  }
}
