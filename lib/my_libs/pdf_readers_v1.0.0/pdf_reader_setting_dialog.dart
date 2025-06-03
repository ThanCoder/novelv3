import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_widgets/t_widgets.dart';

import 'android_screen_orientation_chooser.dart';
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
  final mouseScrollWheelController = TextEditingController();
  final scrollByArrowKeyController = TextEditingController();
  late PdfConfigModel config;

  @override
  void initState() {
    config = widget.config;
    super.initState();
    init();
  }

  void init() {
    mouseScrollWheelController.text = config.scrollByMouseWheel.toString();
    scrollByArrowKeyController.text = config.scrollByArrowKey.toString();
  }

  void _onApply() {
    Navigator.pop(context);
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
              // dart mode
              TListTileWithDesc(
                title: 'Dark Mode',
                trailing: Switch(
                  value: config.isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      config.isDarkMode = value;
                    });
                  },
                ),
              ),
              //text selection
              TListTileWithDesc(
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
              TListTileWithDesc(
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
              TListTileWithDesc(
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
              //on backpress confirm
              Platform.isAndroid
                  ? TListTileWithDesc(
                      title: 'Screen Orientation',
                      desc: 'Portrait,Landscape',
                      trailing: AndroidScreenOrientationChooser(
                        value: config.screenOrientation,
                        onChanged: (type) {
                          config.screenOrientation = type;
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
              //on backpress confirm
              TListTileWithDesc(
                title: 'On Backpress Confirm',
                desc: 'Reader ထဲက ထွက်ရင် အတည်ပြုခြင်း',
                trailing: Switch(
                  value: config.isOnBackpressConfirm,
                  onChanged: (value) {
                    setState(() {
                      config.isOnBackpressConfirm = value;
                    });
                  },
                ),
              ),

              // optional
              const Divider(),
              TListTileWithDesc(
                title: config.isPanLocked ? 'Locked' : 'Lock',
                trailing: Switch.adaptive(
                  value: config.isPanLocked,
                  onChanged: (value) {
                    setState(() {
                      config.isPanLocked = value;
                    });
                  },
                ),
              ),

              //mouse wheel
              TListTileWithDesc(
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
                    onSubmitted: (v) => _onApply(),
                  ),
                ),
              ),
              //mouse wheel
              TListTileWithDesc(
                title: 'Keyboard Scroll Speed',
                trailing: Expanded(
                  child: TTextField(
                    controller: scrollByArrowKeyController,
                    hintText: '50',
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
                        config.scrollByArrowKey = double.parse(value);
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    },
                    onSubmitted: (v) => _onApply(),
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
            _onApply();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
