import 'package:flutter/material.dart';

class ImdbComponent extends StatelessWidget {
  double? value;
  void Function(double imdb) onChanged;
  ImdbComponent({
    super.key,
    required this.value,
    required this.onChanged,
  });

  List<DropdownMenuItem<double>> _getMenuList() {
    List<DropdownMenuItem<double>> list = [];
    final genList = [
      for (double i = 0.1; i <= 10; i += 0.1) i.toStringAsFixed(1)
    ];
    list = genList
        .map((gen) => DropdownMenuItem<double>(
              value: double.parse(gen),
              child: Text(gen),
            ))
        .toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Text('IMDB'),
        DropdownButton<double>(
          value: value,
          items: _getMenuList(),
          onChanged: (value) => onChanged(value!),
        ),
      ],
    );
  }
}
