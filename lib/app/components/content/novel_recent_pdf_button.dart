import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/route_helper.dart';

class NovelRecentPdfButton extends StatelessWidget {
  NovelModel novel;
  NovelRecentPdfButton({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    final res = novel.getRecentPdfReader();
    if (res == null) {
      return const SizedBox.shrink();
    }
    return ElevatedButton(
      onPressed: () {
        goPdfReader(context, res);
      },
      child: const Text('Recent Pdf'),
    );
  }
}
