import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/route_helper.dart';

class NovelRecentPdfButton extends ConsumerWidget {
  NovelModel novel;
  NovelRecentPdfButton({super.key, required this.novel});

  @override
  Widget build(BuildContext context,ref) {
    final res = novel.getRecentPdfReader();
    if (res == null) {
      return const SizedBox.shrink();
    }
    return ElevatedButton(
      onPressed: () {
        goPdfReader(context,ref, res);
      },
      child: const Text('Recent Pdf'),
    );
  }
}
