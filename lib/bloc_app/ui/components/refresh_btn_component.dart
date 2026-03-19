import 'package:flutter/material.dart';

class RefreshBtnComponent extends StatelessWidget {
  final Widget text;
  final void Function()? onClicked;
  const RefreshBtnComponent({super.key, required this.text, this.onClicked});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 3,
      children: [
        text,
        IconButton(
          onPressed: onClicked,
          icon: Icon(Icons.refresh, color: Colors.blue),
        ),
      ],
    );
  }
}
