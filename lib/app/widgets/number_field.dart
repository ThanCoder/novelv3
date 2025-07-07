import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberField extends StatelessWidget {
  TextEditingController? controller;
  Widget? label;
  FocusNode? focusNode;
  int? maxLines;
  void Function(String text)? onChanged;
  void Function(String text)? onSubmitted;
  NumberField({
    super.key,
    this.controller,
    this.label,
    this.focusNode,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        label: label,
      ),
    );
  }
}
