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
  bool isLockScreen = false;
  bool isFullscreen = false;
  bool useProgressiveLoading = true;

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
    isLockScreen = widget.config.isLockScreen;
    isFullscreen = widget.config.isFullscreen;
    useProgressiveLoading = widget.config.useProgressiveLoading;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      contentPadding: const EdgeInsets.all(4),
      title: const Text('Setting'),
      content: Column(
        children: [
          // dart mode
          Card(
            child: SwitchListTile.adaptive(
              title: Text('Dark Mode'),
              value: isDarkMode,
              onChanged: (value) {
                setState(() {
                  isDarkMode = value;
                });
              },
            ),
          ),
          //text selection
          Card(
            child: SwitchListTile.adaptive(
              title: Text('Text Selection'),
              subtitle: Text('PDF Text ကို ကူးယူနိုင်ခြင်း'),
              value: isTextSelection,
              onChanged: (value) {
                setState(() {
                  isTextSelection = value;
                });
              },
            ),
          ),
          //scroll thumb
          Card(
            child: SwitchListTile.adaptive(
              title: Text('Scroll Thumbnail'),
              subtitle: Text('ဘေးဘက်ခြမ်းက Scroll Thumb'),
              value: isShowScrollThumb,
              onChanged: (value) {
                setState(() {
                  isShowScrollThumb = value;
                });
              },
            ),
          ),
          //keep screen
          Card(
            child: SwitchListTile.adaptive(
              title: Text('Keep Screen'),
              subtitle: Text('Screen ကိုအမြဲတမ်းဖွင့်ထားခြင်း'),
              value: isKeepScreen,
              onChanged: (value) {
                setState(() {
                  isKeepScreen = value;
                });
              },
            ),
          ),
          //Screen Orientation
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
          Card(
            child: SwitchListTile.adaptive(
              title: Text('On Backpress Confirm'),
              subtitle: Text('Reader အပြင်ထွက်ခြင်း အတည်ပြုခြင်း'),
              value: isOnBackpressConfirm,
              onChanged: (value) {
                setState(() {
                  isOnBackpressConfirm = value;
                });
              },
            ),
          ),

          Card(
            child: SwitchListTile.adaptive(
              title: Text('Progressive Loading'),
              subtitle: Text('PDF Viewer Loading Page Count'),
              value: useProgressiveLoading,
              onChanged: (value) {
                useProgressiveLoading = value;
                setState(() {});
              },
            ),
          ),
          // optional
          const Divider(),
          //lock
          Card(
            child: SwitchListTile.adaptive(
              title: Text(isLockScreen ? 'Locked' : 'UnLocked'),
              secondary: Icon(isLockScreen ? Icons.lock : Icons.lock_open),
              value: isLockScreen,
              onChanged: (value) {
                setState(() {
                  isLockScreen = value;
                });
              },
            ),
          ),

          // fullscreen
          Card(
            child: SwitchListTile.adaptive(
              title: Text('FullScreen'),
              secondary: Icon(
                isFullscreen ? Icons.fullscreen : Icons.fullscreen_exit,
              ),
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
      isLockScreen: isLockScreen,
      isShowScrollThumb: isShowScrollThumb,
      isTextSelection: isTextSelection,
      screenOrientation: screenOrientation,
      scrollByArrowKey: double.tryParse(scrollByArrowKeyController.text),
      scrollByMouseWheel: double.tryParse(scrollByMouseWheelController.text),
      useProgressiveLoading: useProgressiveLoading,
    );
    widget.onApply(config);
  }
}
