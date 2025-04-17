import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/route_helper.dart';

class NovelRecentTextButton extends StatelessWidget {
  NovelModel novel;
  NovelRecentTextButton({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    final res = novel.getRecentTextReader();
    if (res == null) {
      return const SizedBox.shrink();
    }
    return ElevatedButton(
      onPressed: () {
        goTextReader(context, res);
      },
      child: const Text('Recent Text'),
    );
  }
}
