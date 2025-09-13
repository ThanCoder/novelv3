import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/chapter_reader/reader_theme.dart';

class ThemeChooser extends StatefulWidget {
  ReaderTheme theme;
  void Function(ReaderTheme theme)? onChanged;
  ThemeChooser({super.key, required this.theme, this.onChanged});

  @override
  State<ThemeChooser> createState() => _ThemeChooserState();
}

class _ThemeChooserState extends State<ThemeChooser> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Theme'),
        DropdownButton<ReaderTheme>(
          borderRadius: BorderRadius.circular(4),
          padding: EdgeInsets.all(4),
          value: widget.theme,
          items: _getList,
          onChanged: (value) {
            widget.onChanged?.call(value!);
          },
        ),
      ],
    );
  }

  List<DropdownMenuItem<ReaderTheme>> get _getList {
    return ReaderTheme.getDefaultList
        .map(
          (e) => DropdownMenuItem<ReaderTheme>(value: e, child: Text(e.title)),
        )
        .toList();
  }
}
