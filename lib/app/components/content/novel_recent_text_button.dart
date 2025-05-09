import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/route_helper.dart';

class NovelRecentTextButton extends ConsumerWidget {
  NovelModel novel;
  NovelRecentTextButton({super.key, required this.novel});

  @override
  Widget build(BuildContext context,ref) {
    final res = novel.getRecentTextReader();
    if (res == null) {
      return const SizedBox.shrink();
    }
    return ElevatedButton(
      onPressed: () {
        goTextReader(context,ref, res);
      },
      child: const Text('Recent Text'),
    );
  }
}
