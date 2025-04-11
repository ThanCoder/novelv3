import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/screens/novel_content_screen.dart';
import 'package:provider/provider.dart';

void goNovelContentPage(BuildContext context, NovelModel novel) async {
  await context.read<NovelProvider>().setCurrent(novel);
  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NovelContentScreen(novel: novel),
    ),
  );
}
