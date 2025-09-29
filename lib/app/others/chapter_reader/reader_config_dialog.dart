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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      contentPadding: EdgeInsets.all(6),
      scrollable: true,
      content: TScrollableColumn(
        spacing: 15,
        children: [
          // keep screen
          SwitchListTile.adaptive(
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
          // is backpress confirm
          SwitchListTile.adaptive(
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
          // font
          TNumberField(
            label: Text('Font Size'),
            maxLines: 1,
            controller: fontSizeController,
            // onChanged: (text) {
            //   if (double.tryParse(text) == null) return;
            //   config.fontSize = double.parse(text);
            // },
          ),
          // theme
          _getThemeChanger(),
          // padding
          _getPadding(),
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
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reader Text Padding'),
        TNumberField(
          label: Text('Left-Right'),
          maxLines: 1,
          controller: paddingXController,
          // onChanged: (text) {
          //   if (double.tryParse(text) == null) return;
          //   config.paddingX = double.parse(text);
          // },
        ),
        TNumberField(
          label: Text('Top-Bottom'),
          maxLines: 1,
          controller: paddingYController,
          // onChanged: (text) {
          //   if (double.tryParse(text) == null) return;
          //   config.paddingY = double.parse(text);
          // },
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
      final config = widget.config.copyWith(
        fontSize: double.tryParse(fontSizeController.text),
        isBackpressConfirm: isBackpressConfirm,
        isKeepScreening: isKeepScreening,
        paddingX: double.tryParse(paddingXController.text),
        paddingY: double.tryParse(paddingYController.text),
        theme: theme,
      );
      widget.onUpdated?.call(config);
    } catch (e) {
      showTMessageDialogError(context, e.toString());
    }
  }
}
