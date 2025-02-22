import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TTextField extends StatefulWidget {
  TextEditingController? controller;
  Widget? label;
  String? hintText;
  String? errorText;
  int? maxLines;
  TextInputType? textInputType;
  bool isSelectedAll;
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
    this.isSelectedAll = false,
    this.textInputType,
    this.inputFormatters,
    this.errorText,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
  });

  @override
  State<TTextField> createState() => _TTextFieldState();
}

class _TTextFieldState extends State<TTextField> {
  bool isSelected = false;

  void _selectAll() {
    if (widget.isSelectedAll && widget.controller != null) {
      if (!isSelected) {
        widget.controller!.selection = TextSelection(
            baseOffset: 0, extentOffset: widget.controller!.text.length);
      }
      isSelected = true;
    } else {
      isSelected = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: widget.textInputType,
      inputFormatters: widget.inputFormatters,
      controller: widget.controller,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        label: widget.label,
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
        errorText: widget.errorText,
      ),
      onChanged: widget.onChanged,
      onTap: () {
        _selectAll();
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onSubmitted: widget.onSubmitted,
    );
  }
}
