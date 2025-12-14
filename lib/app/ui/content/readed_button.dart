import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class ReadedButton extends StatelessWidget {
  const ReadedButton({super.key});

  @override
  Widget build(BuildContext context) {
    final currentNovel = context.watch<NovelProvider>().currentNovel;
    final readed = currentNovel == null ? 0 : currentNovel.meta.readed;
    return TextButton(
      onPressed: () {
        if (currentNovel == null) return;
        showTReanmeDialog(
          context,
          barrierDismissible: false,
          title: Text('Change Readed'),
          text: readed.toString(),
          textInputType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          submitText: 'Change',
          onSubmit: (text) {
            final num = int.tryParse(text) ?? 0;
            final novel = currentNovel.copyWith(
              meta: currentNovel.meta.copyWith(readed: num),
            );
            context.read<NovelProvider>().update(novel);
            context.read<NovelProvider>().setCurrentNovel(novel);
          },
        );
      },
      child: Text('Readed: $readed'),
    );
  }
}
