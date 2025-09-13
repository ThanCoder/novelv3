import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/chapter_reader/chapter_reader_config.dart';
import 'package:novel_v3/app/others/chapter_reader/theme_chooser.dart';
import 'package:t_widgets/t_widgets.dart';

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
  late ChapterReaderConfig config;
  final paddingXController = TextEditingController();
  final paddingYController = TextEditingController();
  final fontSizeController = TextEditingController();

  @override
  void initState() {
    config = widget.config;
    super.initState();
    init();
  }

  void init() {
    paddingXController.text = config.paddingX.toString();
    paddingYController.text = config.paddingY.toString();
    fontSizeController.text = config.fontSize.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      contentPadding: EdgeInsets.all(6),
      scrollable: true,
      content: TScrollableColumn(
        spacing: 15,
        children: [
          SwitchListTile.adaptive(
            value: config.isKeepScreening,
            title: Text('Keep Screen'),
            subtitle: Text(
              'Screen မီးဆက်တက်ဖွင့်ထားမယ်...',
              style: TextStyle(fontSize: 12),
            ),
            onChanged: (value) {
              setState(() {
                config.isKeepScreening = value;
              });
            },
          ),
          // font
          TNumberField(
            label: Text('Font Size'),
            maxLines: 1,
            controller: fontSizeController,
            onChanged: (text) {
              if (double.tryParse(text) == null) return;
              config.fontSize = double.parse(text);
            },
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
      theme: config.theme,
      onChanged: (theme) {
        setState(() {
          config.theme = theme;
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
          onChanged: (text) {
            if (double.tryParse(text) == null) return;
            config.paddingX = double.parse(text);
          },
        ),
        TNumberField(
          label: Text('Top-Bottom'),
          maxLines: 1,
          controller: paddingYController,
          onChanged: (text) {
            if (double.tryParse(text) == null) return;
            config.paddingY = double.parse(text);
          },
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
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          widget.onUpdated?.call(config);
        },
        child: Text('Update'),
      ),
    ];
  }
}
