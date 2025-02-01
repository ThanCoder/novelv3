import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/text_reader_config_model.dart';
import 'package:novel_v3/app/widgets/font_list_wiget.dart';
import 'package:novel_v3/app/widgets/list_tile_with_desc.dart';

class TextReaderConfigDialog extends StatefulWidget {
  BuildContext dialogContext;
  TextReaderConfigModel readerConfig;
  String title;
  String contentText;
  String cancelText;
  String submitText;
  void Function() onCancel;
  void Function(TextReaderConfigModel readerConfig) onSubmit;
  TextReaderConfigDialog({
    super.key,
    required this.dialogContext,
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

  @override
  void initState() {
    readerConfig = widget.readerConfig;
    init();
    super.initState();
  }

  void init() {
    fontController.text = readerConfig.fontSize.toInt().toString();
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
                  widget: FontListWiget(
                    fontSize: readerConfig.fontSize.toInt(),
                    onChange: (fontSize) {
                      setState(() {
                        readerConfig.fontSize = fontSize.toDouble();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(widget.dialogContext);
              widget.onCancel();
            },
            child: Text(widget.cancelText),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(widget.dialogContext);
              widget.onSubmit(readerConfig);
            },
            child: Text(widget.submitText),
          ),
        ],
      ),
    );
  }
}
