import 'package:flutter/material.dart';

import '../widgets/index.dart';

class NovelOnlinePage extends StatelessWidget {
  const NovelOnlinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Online'),
      ),
      body: const Center(child: Text('Comming Soon...')),
    );
  }
}
