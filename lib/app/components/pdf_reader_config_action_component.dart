import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/models/pdf_config_model.dart';
import 'package:novel_v3/app/widgets/list_tile_with_desc.dart';
import 'package:novel_v3/app/widgets/t_text_field.dart';

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
                      value: pdfConfig.isTextSelection,
                      onChanged: (value) {
                        setState(() {
                          pdfConfig.isTextSelection = value;
                        });
                      },
                    ),
                  ),
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
