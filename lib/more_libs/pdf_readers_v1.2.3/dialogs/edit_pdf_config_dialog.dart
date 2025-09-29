import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/enums/screen_orientation_types.dart';
import '../types/pdf_config.dart';

class EditPdfConfigDialog extends StatefulWidget {
  final PdfConfig pdfConfig;
  final Widget? title;
  final void Function(PdfConfig updatedConfig) onUpdated;
  const EditPdfConfigDialog({
    super.key,
    required this.pdfConfig,
    required this.onUpdated,
    this.title,
  });

  @override
  State<EditPdfConfigDialog> createState() => _EditPdfConfigDialogState();
}

class _EditPdfConfigDialogState extends State<EditPdfConfigDialog> {
  late PdfConfig config;
  final pageIndexController = TextEditingController();

  @override
  void initState() {
    config = widget.pdfConfig;
    super.initState();
    init();
  }

  void init() {
    pageIndexController.text = config.page.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: widget.title,
      scrollable: true,
      content: Column(
        children: [
          TTextField(
            label: Text('Page Index'),
            controller: pageIndexController,
            maxLines: 1,
            isSelectedAll: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputType: TextInputType.number,
            onChanged: (value) {
              if (value.isEmpty && int.tryParse(value) == null) {
                return;
              }
              config.page = int.parse(value);
            },
            onSubmitted: (_) => _onSubmit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            _onSubmit();
          },
          child: Text('Update'),
        ),
      ],
    );
  }

  void _onSubmit() {
    Navigator.pop(context);
    // reset
    config.screenOrientation = ScreenOrientationTypes.portrait;
    config.offsetDy = 0;
    config.zoom = 0;
    config.isPanLocked = false;

    widget.onUpdated(config);
  }
}
