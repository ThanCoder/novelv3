import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/enums/screen_orientation_types.dart';

import '../components/android_screen_orientation_chooser.dart';
import '../types/pdf_config.dart';

class PdfReaderSettingDialog extends StatefulWidget {
  PdfConfig config;
  void Function(PdfConfig config) onApply;

  PdfReaderSettingDialog({
    super.key,
    required this.config,
    required this.onApply,
  });

  @override
  State<PdfReaderSettingDialog> createState() => _PdfReaderSettingDialogState();
}

class _PdfReaderSettingDialogState extends State<PdfReaderSettingDialog> {
  final scrollByMouseWheelController = TextEditingController();
  final scrollByArrowKeyController = TextEditingController();
  bool isDarkMode = false;
  bool isTextSelection = false;
  bool isShowScrollThumb = false;
  bool isKeepScreen = false;
  late ScreenOrientationTypes screenOrientation;
  bool isOnBackpressConfirm = false;
  bool isPanLocked = false;
  bool isFullscreen = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    scrollByMouseWheelController.text = widget.config.scrollByMouseWheel
        .toString();
    scrollByArrowKeyController.text = widget.config.scrollByArrowKey.toString();
    isDarkMode = widget.config.isDarkMode;
    isTextSelection = widget.config.isTextSelection;
    isShowScrollThumb = widget.config.isShowScrollThumb;
    isKeepScreen = widget.config.isKeepScreen;
    screenOrientation = widget.config.screenOrientation;
    isOnBackpressConfirm = widget.config.isOnBackpressConfirm;
    isPanLocked = widget.config.isPanLocked;
    isFullscreen = widget.config.isFullscreen;
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
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                    });
                  },
                ),
              ),
              //text selection
              TListTileWithDesc(
                title: 'Text Selection',
                desc: 'PDF Text ကို ကူးယူနိုင်ခြင်း',
                trailing: Switch(
                  value: isTextSelection,
                  onChanged: (value) {
                    setState(() {
                      isTextSelection = value;
                    });
                  },
                ),
              ),
              //scroll thumb
              TListTileWithDesc(
                title: 'Scroll Thumbnail',
                desc: 'ဘေးဘက်ခြမ်းက Scroll Thumb',
                trailing: Switch(
                  value: isShowScrollThumb,
                  onChanged: (value) {
                    setState(() {
                      isShowScrollThumb = value;
                    });
                  },
                ),
              ),
              //keep screen
              TListTileWithDesc(
                title: 'Keep Screen',
                desc: 'Screen ကိုအမြဲတမ်းဖွင့်ထားခြင်း',
                trailing: Switch(
                  value: isKeepScreen,
                  onChanged: (value) {
                    setState(() {
                      isKeepScreen = value;
                    });
                  },
                ),
              ),
              //on backpress confirm
              TListTileWithDesc(
                title: 'Screen Orientation',
                desc: 'Working in Android!',
                trailing: AndroidScreenOrientationChooser(
                  value: screenOrientation,
                  onChanged: (type) {
                    screenOrientation = type;
                  },
                ),
              ),
              //on backpress confirm
              TListTileWithDesc(
                title: 'On Backpress Confirm',
                desc: 'Reader ထဲက ထွက်ရင် အတည်ပြုခြင်း',
                trailing: Switch(
                  value: isOnBackpressConfirm,
                  onChanged: (value) {
                    setState(() {
                      isOnBackpressConfirm = value;
                    });
                  },
                ),
              ),
              // optional
              const Divider(),
              //lock
              TListTileWithDesc(
                leading: Icon(isPanLocked ? Icons.lock : Icons.lock_open),
                title: isPanLocked ? 'Locked' : 'UnLocked',
                trailing: Switch.adaptive(
                  value: isPanLocked,
                  onChanged: (value) {
                    setState(() {
                      isPanLocked = value;
                    });
                  },
                ),
              ),
              // fullscreen
              TListTileWithDesc(
                leading: Icon(
                  isFullscreen ? Icons.fullscreen : Icons.fullscreen_exit,
                ),
                title: 'FullScreen',
                trailing: Switch.adaptive(
                  value: isFullscreen,
                  onChanged: (value) {
                    setState(() {
                      isFullscreen = value;
                    });
                  },
                ),
              ),

              //mouse wheel
              TListTileWithDesc(
                leading: Icon(Icons.mouse),
                title: 'Mouse Scroll',
                trailing: Expanded(
                  child: TTextField(
                    controller: scrollByMouseWheelController,
                    hintText: '1.2',
                    textInputType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    onSubmitted: (v) => _onApply(),
                  ),
                ),
              ),
              //mouse wheel
              TListTileWithDesc(
                leading: Icon(Icons.keyboard),
                title: 'Keyboard Scroll Speed',
                trailing: Expanded(
                  child: TTextField(
                    controller: scrollByArrowKeyController,
                    hintText: '50',
                    textInputType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    onSubmitted: (v) => _onApply(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: _getActions(),
    );
  }

  List<Widget> _getActions() {
    return [
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
    ];
  }

  void _onApply() {
    Navigator.pop(context);
    final config = widget.config.copyWith(
      isDarkMode: isDarkMode,
      isFullscreen: isFullscreen,
      isKeepScreen: isKeepScreen,
      isOnBackpressConfirm: isOnBackpressConfirm,
      isPanLocked: isPanLocked,
      isShowScrollThumb: isShowScrollThumb,
      isTextSelection: isTextSelection,
      screenOrientation: screenOrientation,
      scrollByArrowKey: double.tryParse(scrollByArrowKeyController.text),
      scrollByMouseWheel: double.tryParse(scrollByMouseWheelController.text),
    );
    widget.onApply(config);
  }
}
