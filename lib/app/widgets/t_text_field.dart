import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TTextField extends StatelessWidget {
  TextEditingController? controller;
  Widget? label;
  String? hintText;
  String? errorText;
  int? maxLines;
  TextInputType? textInputType;
  List<TextInputFormatter>? inputFormatters;
  void Function(String value)? onChanged;
  void Function(String value)? onSubmitted;
  void Function()? onTap;
  TTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.maxLines = 1,
    this.textInputType,
    this.inputFormatters,
    this.errorText,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: textInputType,
      inputFormatters: inputFormatters,
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        label: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        errorText: errorText,
      ),
      onChanged: onChanged,
      onTap: onTap,
      onSubmitted: onSubmitted,
    );
  }
}
