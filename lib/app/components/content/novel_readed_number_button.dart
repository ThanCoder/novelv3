import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/dialogs/core/index.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:provider/provider.dart';

class NovelReadedNumberButton extends StatefulWidget {
  NovelModel novel;
  NovelReadedNumberButton({super.key, required this.novel});

  @override
  State<NovelReadedNumberButton> createState() =>
      _NovelReadedNumberButtonState();
}

class _NovelReadedNumberButtonState extends State<NovelReadedNumberButton> {
  void _showEdit() {
    showDialog(
      context: context,
      builder: (context) => RenameDialog(
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputType: TextInputType.number,
        title: 'Readed',
        text: widget.novel.readed.toString(),
        onCancel: () {},
        onSubmit: (text) async {
          try {
            if (text.isEmpty) return;
            final num = int.parse(text);
            widget.novel.readed = num;
            await widget.novel.save();
            if (!mounted) return;
            context.read<NovelProvider>().setCurrent(widget.novel);
          } catch (e) {
            if (!mounted) return;
            showDialogMessage(context, e.toString());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showEdit,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Readed: ${widget.novel.readed}',
          style: const TextStyle(color: Colors.blue),
        ),
      ),
    );
  }
}
