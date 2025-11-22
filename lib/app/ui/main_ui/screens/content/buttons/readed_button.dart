import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:novel_v3/app/providers/novel_provider.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/functions/dialog_func.dart';

class ReadedButton extends StatefulWidget {
  const ReadedButton({super.key});

  @override
  State<ReadedButton> createState() => _ReadedButtonState();
}

class _ReadedButtonState extends State<ReadedButton> {
  @override
  Widget build(BuildContext context) {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) {
      return SizedBox.shrink();
    }
    return TextButton(
      child: Text(
        'Readed: ${novel.meta.readed}',
      ).animate().rotate(duration: Duration(milliseconds: 800)),
      onPressed: () {
        showTReanmeDialog(
          barrierDismissible: false,
          context,
          title: Text('ပြင်ဆင်ခြင်း'),
          text: novel.meta.readed.toString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputType: TextInputType.number,
          submitText: 'Update',
          onSubmit: (text) async {
            // novel.setReaded(text);
            await Future.delayed(Duration(milliseconds: 500));
            if (!context.mounted) return;
            context.read<NovelProvider>().refreshNotifier();
            setState(() {});
          },
        );
      },
    );
  }
}
