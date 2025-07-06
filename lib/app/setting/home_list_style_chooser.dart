import 'package:flutter/material.dart';
import 'package:novel_v3/app/setting/home_list_styles.dart';
import 'package:than_pkg/than_pkg.dart';

class HomeListStyleChooser extends StatefulWidget {
  HomeListStyles? value;
  void Function(HomeListStyles value) onChanged;
  HomeListStyleChooser({
    super.key,
    this.value,
    required this.onChanged,
  });

  @override
  State<HomeListStyleChooser> createState() => _HomeListStyleChooserState();
}

class _HomeListStyleChooserState extends State<HomeListStyleChooser> {
  HomeListStyles? value;
  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<HomeListStyles>(
      padding: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(4),
      value: value,
      items: HomeListStyles.values
          .map(
            (e) => DropdownMenuItem<HomeListStyles>(
              value: e,
              child: Text(
                e.name.toCaptalize(),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          this.value = value;
        });
        widget.onChanged(value!);
      },
    );
  }
}
