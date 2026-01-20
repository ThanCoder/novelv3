import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/chapter_reader/chapter_reader_config.dart';
import 'package:novel_v3/app/others/chapter_reader/theme_chooser.dart';
import 'package:t_widgets/t_widgets.dart';

import 'reader_theme.dart';

typedef OnUpdateConfigCallback =
    void Function(ChapterReaderConfig updatedConfig);

class ReaderConfigDialog extends StatefulWidget {
  final ChapterReaderConfig config;
  final OnUpdateConfigCallback? onUpdated;
  const ReaderConfigDialog({super.key, required this.config, this.onUpdated});

  @override
  State<ReaderConfigDialog> createState() => _ReaderConfigDialogState();
}

class _ReaderConfigDialogState extends State<ReaderConfigDialog> {
  final paddingXController = TextEditingController();
  final paddingYController = TextEditingController();
  final fontSizeController = TextEditingController();
  final desktopArrowKeyScrollJumpToOffsetController = TextEditingController();
  bool isKeepScreening = false;
  bool isBackpressConfirm = false;
  late ReaderTheme theme;

  @override
  void initState() {
    isKeepScreening = widget.config.isKeepScreening;
    isBackpressConfirm = widget.config.isBackpressConfirm;
    theme = widget.config.theme;
    paddingXController.text = widget.config.paddingX.toInt().toString();
    paddingYController.text = widget.config.paddingY.toInt().toString();
    fontSizeController.text = widget.config.fontSize.toInt().toString();
    desktopArrowKeyScrollJumpToOffsetController.text = widget
        .config
        .desktopArrowKeyScrollJumpToOffset
        .toInt()
        .toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      contentPadding: EdgeInsets.all(6),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // keep screen
          Card(
            child: SwitchListTile.adaptive(
              value: isKeepScreening,
              title: Text('Keep Screen'),
              subtitle: Text(
                'Screen မီးဆက်တက်ဖွင့်ထားမယ်...',
                style: TextStyle(fontSize: 12),
              ),
              onChanged: (value) {
                setState(() {
                  isKeepScreening = value;
                });
              },
            ),
          ),
          // is backpress confirm
          Card(
            child: SwitchListTile.adaptive(
              value: isBackpressConfirm,
              title: Text('BackPress Confirm'),
              subtitle: Text(
                'ပြန်ထွက် အတည်ပြုခြင်း',
                style: TextStyle(fontSize: 12),
              ),
              onChanged: (value) {
                setState(() {
                  isBackpressConfirm = value;
                });
              },
            ),
          ),
          // font
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TNumberField(
                label: Text('Font Size'),
                maxLines: 1,
                controller: fontSizeController,
              ),
            ),
          ),
          // theme
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _getThemeChanger(),
            ),
          ),
          // padding
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _getPadding(),
            ),
          ),
          // destkop
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TNumberField(
                label: Text('Arrow Key Scroll Jump To Offset'),
                maxLines: 1,
                controller: desktopArrowKeyScrollJumpToOffsetController,
              ),
            ),
          ),
        ],
      ),
      actions: _getActions(),
    );
  }

  Widget _getThemeChanger() {
    return ThemeChooser(
      theme: theme,
      onChanged: (theme) {
        setState(() {
          this.theme = theme;
        });
      },
    );
  }

  Widget _getPadding() {
    return Column(
      spacing: 9,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reader Text Padding'),
        TNumberField(
          label: Text('Left-Right'),
          maxLines: 1,
          controller: paddingXController,
        ),
        TNumberField(
          label: Text('Top-Bottom'),
          maxLines: 1,
          controller: paddingYController,
        ),
      ],
    );
  }

  List<Widget> _getActions() {
    return [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('Close'),
      ),
      TextButton(onPressed: _onSave, child: Text('Apply')),
    ];
  }

  void _onSave() {
    try {
      Navigator.pop(context);

      widget.config.fontSize = double.parse(fontSizeController.text);
      widget.config.isBackpressConfirm = isBackpressConfirm;
      widget.config.isKeepScreening = isKeepScreening;
      widget.config.paddingX = double.parse(paddingXController.text);
      widget.config.paddingY = double.parse(paddingYController.text);
      widget.config.desktopArrowKeyScrollJumpToOffset = double.parse(
        desktopArrowKeyScrollJumpToOffsetController.text,
      );
      widget.config.theme = theme;
      widget.onUpdated?.call(widget.config);
    } catch (e) {
      showTMessageDialogError(context, e.toString());
    }
  }
}
