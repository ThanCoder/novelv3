import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/content/novel_content_home_screen.dart';

import 'novel_dir_db.dart';

void goNovelSeeAllScreen(BuildContext context, String title, List<Novel> list) {
  novelSeeAllScreenNotifier.value = list;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NovelSeeAllScreen(title: title),
    ),
  );
}

Future<void> goContentScreen(BuildContext context, Novel novel) async {
  await context.read<NovelProvider>().setCurrent(novel);
  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NovelContentHomeScreen(),
    ),
  );
}
