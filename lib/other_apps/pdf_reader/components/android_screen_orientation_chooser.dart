import 'package:flutter/material.dart';
import 'package:than_pkg/enums/screen_orientation_types.dart';
import 'package:than_pkg/than_pkg.dart';

class AndroidScreenOrientationChooser extends StatefulWidget {
  ScreenOrientationTypes value;
  void Function(ScreenOrientationTypes type) onChanged;
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
  ScreenOrientationTypes? value;

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<ScreenOrientationTypes>(
      value: value,
      items: _getItems,
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          this.value = value;
        });
        widget.onChanged(value);
      },
    );
  }

  List<DropdownMenuItem<ScreenOrientationTypes>> get _getItems {
    return ScreenOrientationTypes.values
        .map(
          (e) => DropdownMenuItem<ScreenOrientationTypes>(
            value: e,
            child: Text(e.name.toCaptalize(), style: TextStyle(fontSize: 13)),
          ),
        )
        .toList();
  }
}
