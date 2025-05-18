import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:t_widgets/t_widgets.dart';

class PdfConfigEditDialog extends StatefulWidget {
  PdfConfigModel config;
  void Function(PdfConfigModel config) onApply;
  PdfConfigEditDialog({
    super.key,
    required this.config,
    required this.onApply,
  });

  @override
  State<PdfConfigEditDialog> createState() => _PdfConfigEditDialogState();
}

class _PdfConfigEditDialogState extends State<PdfConfigEditDialog> {
  final TextEditingController textController =
      TextEditingController(text: '"page"');
  @override
  void initState() {
    super.initState();
    init();
  }

  String? errorText;
  String? errorDesc;

  void init() {
    textController.text =
        const JsonEncoder.withIndent(' ').convert(widget.config.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: [
          TTextField(
            label: const Text('Config'),
            controller: textController,
            maxLines: null,
            errorText: errorText,
            onChanged: (value) {
              try {
                jsonDecode(value);
                errorText = null;
                errorDesc = null;
              } catch (e) {
                debugPrint(e.toString());
                errorText = 'error ရှိနေပါတယ်။';
                errorText = e.toString();
              }
              setState(() {});
            },
          ),
          // show error
          errorDesc == null
              ? const SizedBox()
              : Expanded(child: Text(errorDesc!)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: errorText != null
              ? null
              : () {
                  Navigator.pop(context);
                  widget.onApply(
                      PdfConfigModel.fromMap(jsonDecode(textController.text)));
                },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
