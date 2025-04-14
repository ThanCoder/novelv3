import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/core/index.dart';
import 'pdf_config_model.dart';

class PdfReaderSettingDialog extends StatefulWidget {
  PdfConfigModel config;
  void Function(PdfConfigModel config) onApply;

  PdfReaderSettingDialog({
    super.key,
    required this.config,
    required this.onApply,
  });

  @override
  State<PdfReaderSettingDialog> createState() => _PdfReaderSettingDialogState();
}

class _PdfReaderSettingDialogState extends State<PdfReaderSettingDialog> {
  TextEditingController mouseScrollWheelController = TextEditingController();
  late PdfConfigModel config;

  @override
  void initState() {
    config = widget.config;
    super.initState();
    init();
  }

  void init() {
    mouseScrollWheelController.text = config.scrollByMouseWheel.toString();
  }

  void _onApply() {
    widget.onApply(config);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(4),
      title: const Text('Setting'),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: SingleChildScrollView(
          child: Column(
            children: [
              //text selection
              ListTileWithDesc(
                title: 'Text Selection',
                desc: 'PDF Text ကို ကူးယူနိုင်ခြင်း',
                trailing: Switch(
                  value: config.isTextSelection,
                  onChanged: (value) {
                    setState(() {
                      config.isTextSelection = value;
                    });
                  },
                ),
              ),
              //scroll thumb
              ListTileWithDesc(
                title: 'Scroll Thumbnail',
                desc: 'ဘေးဘက်ခြမ်းက Scroll Thumb',
                trailing: Switch(
                  value: config.isShowScrollThumb,
                  onChanged: (value) {
                    setState(() {
                      config.isShowScrollThumb = value;
                    });
                  },
                ),
              ),
              //keep screen
              ListTileWithDesc(
                title: 'Keep Screen',
                desc: 'Screen ကိုအမြဲတမ်းဖွင့်ထားခြင်း',
                trailing: Switch(
                  value: config.isKeepScreen,
                  onChanged: (value) {
                    setState(() {
                      config.isKeepScreen = value;
                    });
                  },
                ),
              ),
              //mouse wheel
              ListTileWithDesc(
                title: 'Mouse Scroll',
                trailing: Expanded(
                  child: TTextField(
                    controller: mouseScrollWheelController,
                    hintText: '1.2',
                    textInputType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*$'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      try {
                        config.scrollByMouseWheel = double.parse(value);
                      } catch (e) {
                        debugPrint(e.toString());
                      }
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
