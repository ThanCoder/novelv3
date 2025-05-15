import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/core/index.dart';
import 'text_reader_config_model.dart';

class TextReaderSettingDialog extends StatefulWidget {
  TextReaderConfigModel config;
  void Function(TextReaderConfigModel config) onApply;
  TextReaderSettingDialog({
    super.key,
    required this.config,
    required this.onApply,
  });

  @override
  State<TextReaderSettingDialog> createState() =>
      _TextReaderSettingDialogState();
}

class _TextReaderSettingDialogState extends State<TextReaderSettingDialog> {
  final TextEditingController paddingController = TextEditingController();
  final TextEditingController fontSizeController = TextEditingController();
  @override
  void initState() {
    config = widget.config;
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  late TextReaderConfigModel config;

  void init() {
    paddingController.text = config.padding.toInt().toString();
    fontSizeController.text = config.fontSize.toInt().toString();
  }

  void _onApply() {
    if (double.tryParse(fontSizeController.text) != null) {
      config.fontSize = double.parse(fontSizeController.text);
    }
    if (double.tryParse(paddingController.text) != null) {
      config.padding = double.parse(paddingController.text);
    }
    widget.onApply(config);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          children: [
            // isKeepScreen
            ListTileWithDescWidget(
              widget1: const Text('Is Keep Screen'),
              widget2: Switch(
                value: config.isKeepScreen,
                onChanged: (value) {
                  setState(() {
                    config.isKeepScreen = value;
                  });
                },
              ),
            ),
            // Padding
            ListTileWithDescWidget(
              widget1: const Text('Padding'),
              widget2: SizedBox(
                width: 80,
                child: TTextField(
                  controller: paddingController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputType: TextInputType.number,
                ),
              ),
            ),
            //Font Size
            ListTileWithDescWidget(
              widget1: const Text('Font Size'),
              widget2: SizedBox(
                width: 80,
                child: TTextField(
                  controller: fontSizeController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _onApply();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
