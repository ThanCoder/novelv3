import 'package:flutter/material.dart';

class N3DataExportConfirmDialog extends StatefulWidget {
  void Function(bool isSetPassword) onExport;
  N3DataExportConfirmDialog({super.key, required this.onExport});

  @override
  State<N3DataExportConfirmDialog> createState() =>
      _N3DataExportConfirmDialogState();
}

class _N3DataExportConfirmDialogState extends State<N3DataExportConfirmDialog> {
  bool isSetPassword = true;
  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      scrollable: true,
      content: Column(
        children: [
          SwitchListTile.adaptive(
            title: Text('Data Password'),
            subtitle: Text(
              'Data ကိုအခြားသူ မဖွင့်နိုင်အောင် Password ပေးထားချင်ပါသလား?။',
            ),
            value: isSetPassword,
            onChanged: (value) {
              setState(() {
                isSetPassword = value;
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
          child: Text('မလုပ်တော့ပါ'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onExport(isSetPassword);
          },
          child: Text('ထုတ်မယ်'),
        ),
      ],
    );
  }
}
