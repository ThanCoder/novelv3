import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/components/android_screen_orientation_chooser.dart';
import 'package:novel_v3/app/pdf_readers/pdf_config_model.dart';

import '../widgets/index.dart';

class PdfReaderConfigActionComponent extends StatefulWidget {
  PdfConfigModel pdfConfig;
  void Function(PdfConfigModel pdfConfig) onApply;

  PdfReaderConfigActionComponent({
    super.key,
    required this.pdfConfig,
    required this.onApply,
  });

  @override
  State<PdfReaderConfigActionComponent> createState() =>
      _PdfReaderConfigActionComponentState();
}

class _PdfReaderConfigActionComponentState
    extends State<PdfReaderConfigActionComponent> {
  late PdfConfigModel pdfConfig;
  TextEditingController mouseScrollWheelController = TextEditingController();

  @override
  void initState() {
    pdfConfig = widget.pdfConfig;
    super.initState();
    mouseScrollWheelController.text = pdfConfig.scrollByMouseWheel.toString();
  }

  void _showMenu() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          contentPadding: const EdgeInsets.all(4),
          title: const Text('Setting'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //scroll thumb
                  ListTileWithDesc(
                    title: 'Scroll Thumbnail',
                    desc: 'ဘေးဘက်ခြမ်းက Scroll Thumb',
                    trailing: Switch(
                      value: pdfConfig.isShowScrollThumb,
                      onChanged: (value) {
                        setState(() {
                          pdfConfig.isShowScrollThumb = value;
                        });
                      },
                    ),
                  ),
                  //keep screen
                  ListTileWithDesc(
                    title: 'Keep Screen',
                    desc: 'Screen ကိုအမြဲတမ်းဖွင့်ထားခြင်း',
                    trailing: Switch(
                      value: pdfConfig.isKeepScreen,
                      onChanged: (value) {
                        setState(() {
                          pdfConfig.isKeepScreen = value;
                        });
                      },
                    ),
                  ),
                  //on backpress confirm
                  Platform.isAndroid
                      ? ListTileWithDesc(
                          title: 'Screen Orientation',
                          desc: 'Portrait,Landscape',
                          trailing: AndroidScreenOrientationChooser(
                            value: pdfConfig.screenOrientation,
                            onChanged: (type) {
                              pdfConfig.screenOrientation = type;
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                  //on backpress confirm
                  ListTileWithDesc(
                    title: 'On Backpress Confirm',
                    desc: 'Reader ထဲက ထွက်ရင် အတည်ပြုခြင်း',
                    trailing: Switch(
                      value: pdfConfig.isOnBackpressConfirm,
                      onChanged: (value) {
                        setState(() {
                          pdfConfig.isOnBackpressConfirm = value;
                        });
                      },
                    ),
                  ),

                  //text selection
                  ListTileWithDesc(
                    title: 'Text Selection',
                    desc: 'PDF Text ကို ကူးယူနိုင်ခြင်း',
                    trailing: Switch(
                      value: pdfConfig.isTextSelection,
                      onChanged: (value) {
                        setState(() {
                          pdfConfig.isTextSelection = value;
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
                        textInputType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value.isEmpty) return;
                          try {
                            pdfConfig.scrollByMouseWheel = double.parse(value);
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
                widget.onApply(pdfConfig);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showMenu,
      icon: const Icon(Icons.more_vert),
    );
  }
}
