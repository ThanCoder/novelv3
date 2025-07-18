import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/route_helper.dart';

class NovelChapterStartButton extends ConsumerWidget {
  NovelModel novel;
  NovelChapterStartButton({super.key, required this.novel});

  bool isExists(String path) {
    return File(path).existsSync();
  }

  @override
  Widget build(BuildContext context,ref) {
    String path = '${novel.path}/1';
    if (!File(path).existsSync()) {
      return const SizedBox.shrink();
    }
    return ElevatedButton(
      onPressed: () {
        final chapter = ChapterModel.fromPath(path);
        goTextReader(context,ref, chapter);
      },
      child: const Text('Start Read'),
    );
  }
}
