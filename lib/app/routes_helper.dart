import 'package:flutter/material.dart';
import 'package:novel_v3/app/screens/content/novel_content_home_screen.dart';
import 'package:provider/provider.dart';

import 'novel_dir_app.dart';
import 'screens/forms/edit_novel_form.dart';

void goEditNovelForm(BuildContext context, {required Novel novel}) {
  goRoute(
    context,
    builder: (context) => EditNovelForm(
      novel: novel,
      onUpdated: (updatedNovel) {},
    ),
  );
}

void goNovelSeeAllScreen(BuildContext context, String title, List<Novel> list) {
  novelSeeAllScreenNotifier.value = list;
  goRoute(
    context,
    builder: (context) => NovelSeeAllScreen(title: title),
  );
}

Future<void> goNovelContentScreen(BuildContext context, Novel novel) async {
  await context.read<NovelProvider>().setCurrent(novel);
  if (!context.mounted) return;
  goRoute(
    context,
    builder: (context) => NovelContentHomeScreen(),
  );
}

void closeContext(BuildContext context) {
  Navigator.pop(context);
}

void goRoute(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
}) {
  Navigator.push(context, MaterialPageRoute(builder: builder));
}
