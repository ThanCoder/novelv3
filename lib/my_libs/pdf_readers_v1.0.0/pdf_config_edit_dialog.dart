import 'package:flutter/material.dart';
import 'package:novel_v3/app/widgets/number_field.dart';
import 'package:novel_v3/my_libs/pdf_readers_v1.0.0/pdf_config_model.dart';

class PdfConfigEditDialog extends StatefulWidget {
  PdfConfigModel value;
  void Function(PdfConfigModel value) onApply;
  PdfConfigEditDialog({
    super.key,
    required this.value,
    required this.onApply,
  });

  @override
  State<PdfConfigEditDialog> createState() => _PdfConfigEditDialogState();
}

class _PdfConfigEditDialogState extends State<PdfConfigEditDialog> {
  late PdfConfigModel config;
  final pageController = TextEditingController();
  String? error;

  @override
  void initState() {
    config = widget.value;
    pageController.text = config.page.toString();

    super.initState();
  }

  void _save() async {
    try {
      // check new page and old page number
      final pageNumber = int.parse(pageController.text);
      if (pageNumber != config.page) {
        config.page = pageNumber;
        config.offsetDy = 0;
      }

      error = null;
      setState(() {});
      Navigator.pop(context);
      // call back
      widget.onApply(config);
    } catch (e) {
      error = e.toString();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      scrollable: true,
      content: Column(
        children: [
          // error text
          error != null
              ? Text(
                  error ?? '',
                  style: const TextStyle(color: Colors.red),
                )
              : const SizedBox.shrink(),
          NumberField(
            label: const Text('Page Number'),
            controller: pageController,
            onChanged: (text) {
              final res = int.tryParse(text);
              if (res == null) {
                setState(() {
                  error = 'page number is required!';
                });
                return;
              }
              // success
              setState(() {
                error = null;
              });
            },
          ),
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
          onPressed: error != null ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
