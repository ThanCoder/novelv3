import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/other_apps/pdf_reader/types/pdf_config.dart';
import 'package:novel_v3/other_apps/pdf_reader/types/pdf_reader_type.dart';

class PdfReaderTypeChooserDialog extends StatefulWidget {
  final PdfConfig config;
  final void Function(PdfConfig config) onChanged;
  const PdfReaderTypeChooserDialog({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<PdfReaderTypeChooserDialog> createState() =>
      _PdfReaderTypeChooserDialogState();
}

class _PdfReaderTypeChooserDialogState
    extends State<PdfReaderTypeChooserDialog> {
  final list = PdfReaderType.values;
  PdfReaderType? value = PdfReaderType.RXPdfReader;

  @override
  void initState() {
    value = widget.config.readerType;
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DropdownButton<PdfReaderType>(
        value: value,
        items: list
            .map(
              (e) => DropdownMenuItem<PdfReaderType>(
                value: e,
                child: Text(StringCoreExtensions(e.name).toCaptalize),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            this.value = value;
          });
          // PdfReaderTypeChooserDialog.setType(this.value!);
          widget.onChanged(widget.config.copyWith(readerType: value));
        },
      ),
    );
  }
}
