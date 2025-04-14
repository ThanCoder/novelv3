import 'package:flutter/material.dart';
import 'package:than_pkg/enums/screen_orientation_types.dart';

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
          value: ScreenOrientationTypes.Portrait.name,
          child: Text(
            ScreenOrientationTypes.Portrait.name,
          ),
        ),
        DropdownMenuItem<String>(
          value: ScreenOrientationTypes.Landscape.name,
          child: Text(
            ScreenOrientationTypes.Landscape.name,
          ),
        ),
      ],
      onChanged: (_value) {
        if (_value == null) return;
        setState(() {
          value = _value;
        });
        widget.onChanged(_value);
      },
    );
  }
}
