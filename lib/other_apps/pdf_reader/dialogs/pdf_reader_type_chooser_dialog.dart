import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_pkg/t_database/t_recent_db.dart';

enum PdfReaderType { list, singlePage }

class PdfReaderTypeChooserDialog extends StatefulWidget {
  static Future<void> setType(PdfReaderType type) async {
    await TRecentDB.getInstance.putString('PdfReaderType', type.name);
  }

  static PdfReaderType getType() {
    final name = TRecentDB.getInstance.getString('PdfReaderType');
    if (name == PdfReaderType.singlePage.name) {
      return PdfReaderType.singlePage;
    }
    return PdfReaderType.list;
  }

  const PdfReaderTypeChooserDialog({super.key});

  @override
  State<PdfReaderTypeChooserDialog> createState() =>
      _PdfReaderTypeChooserDialogState();
}

class _PdfReaderTypeChooserDialogState
    extends State<PdfReaderTypeChooserDialog> {
  final list = PdfReaderType.values;
  PdfReaderType? value = PdfReaderType.list;

  @override
  void initState() {
    value = PdfReaderTypeChooserDialog.getType();
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
                child: Text(e.name.toCaptalize),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            this.value = value;
          });
          PdfReaderTypeChooserDialog.setType(this.value!);
        },
      ),
    );
  }
}
