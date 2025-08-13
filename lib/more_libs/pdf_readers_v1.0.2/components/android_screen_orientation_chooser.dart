import 'package:flutter/material.dart';
import 'package:than_pkg/enums/screen_orientation_types.dart';
import 'package:than_pkg/than_pkg.dart';

class AndroidScreenOrientationChooser extends StatefulWidget {
  String value;
  void Function(String type) onChanged;
  AndroidScreenOrientationChooser({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<AndroidScreenOrientationChooser> createState() =>
      _AndroidScreenOrientationChooserState();
}

class _AndroidScreenOrientationChooserState
    extends State<AndroidScreenOrientationChooser> {
  String? value;

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      items: [
        DropdownMenuItem<String>(
          value: ScreenOrientationTypes.portrait.name,
          child: Text(ScreenOrientationTypes.portrait.name.toCaptalize()),
        ),
        DropdownMenuItem<String>(
          value: ScreenOrientationTypes.landscape.name,
          child: Text(ScreenOrientationTypes.landscape.name.toCaptalize()),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          this.value = value;
        });
        widget.onChanged(value);
      },
    );
  }
}
