import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/models/text_reader_config_model.dart';
import 'package:novel_v3/app/widgets/font_list_wiget.dart';
import 'package:novel_v3/app/widgets/list_tile_with_desc.dart';
import 'package:novel_v3/app/widgets/t_text_field.dart';

class TextReaderConfigDialog extends StatefulWidget {
  TextReaderConfigModel readerConfig;
  String title;
  String contentText;
  String cancelText;
  String submitText;
  void Function() onCancel;
  void Function(TextReaderConfigModel readerConfig) onSubmit;
  TextReaderConfigDialog({
    super.key,
    required this.readerConfig,
    required this.onCancel,
    required this.onSubmit,
    this.title = 'Content Setting',
    this.contentText = '',
    this.cancelText = 'Cancel',
    this.submitText = 'Submit',
  });

  @override
  State<TextReaderConfigDialog> createState() => _TextReaderConfigDialogState();
}

class _TextReaderConfigDialogState extends State<TextReaderConfigDialog> {
  late TextReaderConfigModel readerConfig;
  TextEditingController fontController = TextEditingController();
  TextEditingController paddingController = TextEditingController();

  @override
  void initState() {
    readerConfig = widget.readerConfig;
    init();
    super.initState();
  }

  void init() {
    fontController.text = readerConfig.fontSize.toInt().toString();
    paddingController.text = readerConfig.padding.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      child: AlertDialog(
        title: Text(widget.title),
        content: SizedBox(
          height: 200,
          width: width > 400 ? width * 0.6 : width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                //font size
                ListTileWithDesc(
                  title: 'Font Size',
                  trailing: FontListWiget(
                    fontSize: readerConfig.fontSize.toInt(),
                    onChange: (fontSize) {
                      setState(() {
                        readerConfig.fontSize = fontSize.toDouble();
                      });
                    },
                  ),
                ),
                //Keep Screen
                ListTileWithDesc(
                  title: 'Keep Screen',
                  trailing: Switch(
                    value: readerConfig.isKeepScreen,
                    onChanged: (value) {
                      setState(() {
                        readerConfig.isKeepScreen = value;
                      });
                    },
                  ),
                ),
                //padding
                ListTileWithDesc(
                  title: 'Padding',
                  trailing: Expanded(
                    child: TTextField(
                      controller: paddingController,
                      hintText: 'Padding',
                      textInputType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$'))
                      ],
                      onChanged: (value) {
                        if (value.isEmpty) return;
                        readerConfig.padding = double.parse(value);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCancel();
            },
            child: Text(widget.cancelText),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSubmit(readerConfig);
            },
            child: Text(widget.submitText),
          ),
        ],
      ),
    );
  }
}
