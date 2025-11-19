import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_widgets/t_widgets.dart';
import '../types/pdf_config.dart';

class EditPdfConfigDialog extends StatefulWidget {
  final PdfConfig pdfConfig;
  final Widget? title;
  final bool allClearOtherConfig;
  final void Function(PdfConfig updatedConfig) onUpdated;
  const EditPdfConfigDialog({
    super.key,
    required this.pdfConfig,
    required this.onUpdated,
    this.title,
    this.allClearOtherConfig = true,
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
              config = config.copyWith(page: int.parse(value));
            },
            onSubmitted: (_) => _onSubmit(),
          ),
        ],
      ),
      actions: _getActions(),
    );
  }

  List<Widget> _getActions() {
    return [
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
    ];
  }

  void _onSubmit() {
    Navigator.pop(context);
    // reset
    config = config.copyWith(
      isLockScreen: !widget.allClearOtherConfig ? null : false,
    );

    widget.onUpdated(config);
  }
}
