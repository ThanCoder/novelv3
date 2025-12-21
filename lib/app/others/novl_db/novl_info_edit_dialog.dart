import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/others/novl_db/novl_info.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:t_widgets/widgets/index.dart';

class NovlInfoEditDialog extends StatefulWidget {
  final Novel? novel;
  final void Function(NovlInfo info) onSubmit;
  const NovlInfoEditDialog({super.key, this.novel, required this.onSubmit});

  @override
  State<NovlInfoEditDialog> createState() => _NovlInfoEditDialogState();
}

class _NovlInfoEditDialogState extends State<NovlInfoEditDialog> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    if (widget.novel != null) {
      final info = StringBuffer();
      // chapter db
      info.writeln('ChapterDB: ');
      info.writeln('chapters.db');
      // pdf
      info.writeln('\nPDF: ');
      for (var pdf in widget.novel!.getPDFFiles) {
        info.writeln(pdf);
      }

      // config
      info.writeln('\nConfig Files: ');
      for (var name in widget.novel!.getConfigFiles) {
        info.writeln(name);
      }

      controller.text = info.toString();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text('Novl Info Edit'),
      scrollable: true,
      content: TTextField(
        label: Text('အကြောင်းအရာများ ရေးသားပါ'),
        maxLines: null,
        // autofocus: true,
        controller: controller,
      ),
      actions: [
        TextButton(
          onPressed: () {
            closeContext(context);
          },
          child: Text('close'),
        ),
        TextButton(
          onPressed: () {
            closeContext(context);
            widget.onSubmit(NovlInfo(desc: controller.text));
          },
          child: Text('Export'),
        ),
      ],
    );
  }
}
