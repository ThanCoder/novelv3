import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:t_widgets/t_widgets.dart';

class BackgroundScaffold extends StatelessWidget {
  List<Widget> stackChildren;
  BackgroundScaffold({
    super.key,
    required this.stackChildren,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final novel = ref.watch(novelNotifierProvider).novel;
      if (novel == null) return const Text('novel is null');
      return Scaffold(
        body: Stack(
          children: [
            // background cover
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: 0.3,
                duration: const Duration(seconds: 2),
                child: appConfigNotifier.value.isShowNovelContentBgImage
                    ? TImageFile(path: novel.coverPath)
                    : null,
              ),
            ),
            ...stackChildren,
          ],
        ),
      );
    });
  }
}
